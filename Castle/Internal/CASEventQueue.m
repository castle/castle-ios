//
//  CASEventStorage.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEventQueue.h"

#import "CASUtils.h"
#import "CASEvent.h"
#import "CASScreen.h"
#import "CASCustom.h"
#import "CASMonitor.h"
#import "CASAPIClient.h"
#import "Castle+Util.h"

static NSString *CASEventStorageBaseFolder = @"/castle/";
static NSString *CASEventStorageFilename = @"events";
static NSUInteger CASMonitorMaxBatchSize = 20;

@interface CASEventQueue ()
@property (nonatomic, strong, nullable) CASAPIClient *client;
@property (nonatomic, strong) NSMutableArray<CASEvent *> *eventQueue;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *task;
@property (nonatomic, copy, readwrite, nullable) NSString *userJwt;
@end

@implementation CASEventQueue

static dispatch_queue_t CASEventStorageQueue(void) {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.castle.CASEventStorageQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Immediate initialize
        self.eventQueue = [[NSMutableArray alloc] init];
        self.client = [CASAPIClient clientWithConfiguration:[Castle configuration]];

        dispatch_async(CASEventStorageQueue(), ^{
            NSArray *storedEvents = [self storedQueue];
            if (storedEvents.count > 0) {
                // Prepend to current queue
                NSMutableArray *combined = [storedEvents mutableCopy];
                [combined addObjectsFromArray:self.eventQueue];
                self.eventQueue = combined;
            }
        });
    }
    return self;
}

- (NSUInteger)count {
    __block NSUInteger count = 0;
    dispatch_sync(CASEventStorageQueue(), ^{
        count = self.eventQueue.count;
    });
    return count;
}

#pragma mark - Storage

- (void)storedQueueWithCompletion:(void (^)(NSArray *queue))completion
{
    dispatch_async(CASEventStorageQueue(), ^{
        NSArray *queue = [self storedQueue];
        self.eventQueue = [queue mutableCopy];
        
        // Call completion on main thread
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(queue);
            });
        }
    });
}

- (NSArray<CASEvent *> *)storedQueue
{
    // Migrate storage if neccessary
    [self migrateStorageIfNeccessary];

    // Read queue from file
    NSArray *queue = [self readQueueFromFile:self.storagePath];
    if (queue == nil) {
        queue = @[];
    }
    return queue;
}

- (NSArray<CASEvent *> *)storedQueueSync
{
    __block NSArray *queue = nil;
    dispatch_sync(CASEventStorageQueue(), ^{
        queue = [self storedQueue];
    });
    return queue;
}

- (void)persistQueue:(NSArray<CASEvent *> *)queue
{
    [self migrateStorageIfNeccessary];

    BOOL persisted = NO;
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:queue requiringSecureCoding:YES error:&error];
        if(data != nil && error == nil) {
            persisted = [data writeToFile:self.storagePath atomically:YES];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        persisted = [NSKeyedArchiver archiveRootObject:queue toFile:self.storagePath];
#pragma clang diagnostic pop
    }

    if(persisted) {
        CASLog(@"%ld events written to: %@", queue.count, self.storagePath);
    } else {
        CASLog(@"WARNING! Event queue couldn't be persisted (%@)", self.storagePath);
    }

    NSError *error = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:self.storagePath];
    if(![fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
        CASLog(@"Failed to exclude event queue data (%@) from iCloud backup. Error: %@", self.storagePath, error);
    }
}

- (void)clearQueue
{
    dispatch_async(CASEventStorageQueue(), ^{
        if (self.eventQueue.count == 0) {
            CASLog(@"Queue doesn't contain any events no need to clear.");
            return;
        }
        
        self.eventQueue = [[NSMutableArray alloc] init];
        [self persistQueue:self.eventQueue];
    });
}

#pragma mark - Queue

- (void)queueEvent:(CASEvent *)event
{
    if(!event) {
        CASLog(@"Can't enqueue nil event");
        return;
    }
    
    if([Castle userJwt] == nil) {
        CASLog(@"No user jwt set, won't queue event");
        return;
    }
    
    if(![Castle isReady]) {
        CASLog(@"SDK not yet ready, won't queue event: %@, of type: %@", event.name, event.type);
        return;
    }
    
    dispatch_async(CASEventStorageQueue(), ^{
        // Trim queue before adding element to make sure it never exceeds maxQueueLimit
        [self trimQueue];
        
        // Add event to the queue
        CASLog(@"Queing event: %@", event);
        [self.eventQueue addObject:event];
        
        // Persist queue to disk
        [self persistQueue:self.eventQueue];
        
        NSUInteger flushLimit = [Castle configuration].flushLimit;
        
        // Flush queue if the number of events exceeds the flush limit
        if(self.eventQueue.count >= flushLimit) {
            // very first event should be fired immediately
            CASLog(@"Event queue exceeded flush limit (%ld). Flushing events.", flushLimit);
            [self flush];
        }
    });
}

# pragma mark - Flushing

- (void)flush
{
    if(![Castle isReady]) {
        CASLog(@"SDK not yet ready, won't flush events.");
        return;
    }
    
    if([Castle userJwt] == nil) {
        CASLog(@"No user jwt set, clearing the queue.");
        [self clearQueue];
        return;
    }
    
    dispatch_async(CASEventStorageQueue(), ^{
        if(self.task != nil) {
            CASLog(@"Queue is already being flushed. Won't flush again.");
            return;
        }
        
        NSArray *batch = @[];
        if (self.eventQueue.count >= CASMonitorMaxBatchSize) {
            batch = [self.eventQueue subarrayWithRange:NSMakeRange(0, CASMonitorMaxBatchSize)];
        } else {
            batch = [NSArray arrayWithArray:self.eventQueue];
        }
        
        CASLog(@"Flushing %ld of %ld queued events", batch.count, self.eventQueue.count);
        
        __block CASMonitor *monitorModel = [CASMonitor monitorWithEvents:batch];
        
        // Nil monitor model object means there's no events to flush
        if(!monitorModel) {
            return;
        }
        
        self.task = [self.client dataTaskWithPath:@"monitor" postData:[monitorModel JSONData] completion:^(id responseObject, NSURLResponse *response, NSError *error) {
            dispatch_async(CASEventStorageQueue(), ^{
                if(error != nil) {
                    CASLog(@"Flush failed with error: %@", error);
                    self.task = nil;
                    return;
                }
                
                // Remove successfully flushed events from queue and persist
                [self.eventQueue removeObjectsInArray:monitorModel.events];
                [self persistQueue:self.eventQueue];
                
                self.task = nil;
                
                CASLog(@"Successfully flushed (%ld) events", monitorModel.events.count);
                
                if ([self eventQueueExceedsFlushLimit] && self.eventQueue.count > 0) {
                    CASLog(@"Current event queue still exceeds flush limit. Flush again");
                    [self flush];
                }
            });
        }];
        
        [self.task resume];
    });
}

#pragma mark - Private

- (void)trimQueue
{
    // Trim queue to maxQueueLimit - 1. This method is only called when queuing an event
    NSUInteger maxQueueLimit = [Castle configuration].maxQueueLimit - 1;
    
    // If the queue doesn't exceed maxQueueLimit just return
    if(self.eventQueue.count < maxQueueLimit) {
        return;
    }
    
    // Remove the oldest excess events from the queue
    NSRange trimRange = NSMakeRange(0, self.eventQueue.count - maxQueueLimit);
    CASLog(@"Queue (size %ld) will exceed maxQueueLimit (%ld). Will trim %ld events from queue.", self.eventQueue.count, maxQueueLimit, trimRange.length);
    [self.eventQueue removeObjectsInRange:trimRange];
}

- (BOOL)eventQueueExceedsFlushLimit
{
    return [self.eventQueue count] >= [Castle configuration].flushLimit;
}

- (void)createStoragePathIfNeccessary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *storagePath = [self storageDirectory];
    if (![fileManager fileExistsAtPath:storagePath isDirectory:NULL]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:storagePath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error != nil) {
            CASLog(@"Failed to create storage path: %@", error.localizedDescription);
        }
    }
}

- (NSArray<CASEvent *> *)readQueueFromFile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data.length == 0) {
        return @[];
    }

    NSArray *queue = @[];
    if (@available(iOS 14.0, *)) {
        NSError *error = nil;
        NSSet *classes = [NSSet setWithArray:@[CASEvent.self, CASScreen.self, CASCustom.self]];
        queue = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClasses:classes fromData:data error:&error];
        if(error != nil) {
            CASLog(@"Failed to load events from file, error: %@", error.localizedDescription);
            queue = @[];
        }
    } else {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            queue = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            CASLog(@"Failed to load events from file, error: %@", [exception callStackSymbols]);
            queue = @[];
        }
    }
    CASLog(@"%ld events read from: %@", queue.count, filePath);
    return queue;
}

#pragma mark - Migration

- (void)migrateStorageIfNeccessary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *oldStoragePath = [self oldStoragePath];

    if ([fileManager fileExistsAtPath:oldStoragePath isDirectory:NULL]) {
        // Create new storage path if neccessary
        [self createStoragePathIfNeccessary];
        
        NSString *newStoragePath = [self storagePath];
        NSString *oldStorageDirectory = [self oldStorageDirectory];
        NSError *error = nil;
      
        // Move old events file to new storage path
        [fileManager moveItemAtPath:oldStoragePath toPath:newStoragePath error:&error];
        if(error != nil) {
            CASLog(@"Failed to move old storage path: %@, to new storage path: %@, error: %@", oldStoragePath, newStoragePath, error.localizedDescription);
        }
        
        // Remove old storage directory
        [fileManager removeItemAtPath:oldStorageDirectory error:&error];
        if(error != nil) {
            CASLog(@"Failed to move old storage directory: %@", error.localizedDescription);
        }
        
        return;
    }
    
    [self createStoragePathIfNeccessary];
}

#pragma mark - Storage paths

- (NSString *)oldStorageDirectory
{
    return [[self documentsDirectory] stringByAppendingString:CASEventStorageBaseFolder];
}

- (NSString *)oldStoragePath
{
    return [[self oldStorageDirectory] stringByAppendingString:CASEventStorageFilename];
}

- (NSString *)storageDirectory
{
    return [[self applicationSupportDirectory] stringByAppendingString:CASEventStorageBaseFolder];
}

- (NSString *)storagePath
{
    return [[self storageDirectory] stringByAppendingString:CASEventStorageFilename];
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

- (NSString *)applicationSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

@end
