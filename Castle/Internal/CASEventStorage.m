//
//  CASEventStorage.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEventStorage.h"

#import "CASUtils.h"
#import "CASEvent.h"
#import "CASScreen.h"
#import "CASCustom.h"

static NSString *CASEventStorageBaseFolder = @"/castle/";
static NSString *CASEventStorageFilename = @"events";

@implementation CASEventStorage

#pragma mark - Storage

+ (NSArray *)storedQueue
{    
    // Migrate storage if neccessary
    [self.class migrateStorageIfNeccessary];
    
    // Read queue from file
    NSArray *queue = [self readQueueFromFile:self.storagePath];
    if (queue == nil) {
        queue = @[];
        [self persistQueue:queue];
    }
    return queue;
}

+ (void)persistQueue:(NSArray *)queue
{
    // Migrate storage if neccessary
    [self.class migrateStorageIfNeccessary];
    
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

#pragma mark - Private

+ (void)createStoragePathIfNeccessary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *storagePath = [self.class storageDirectory];
    if (![fileManager fileExistsAtPath:storagePath isDirectory:NULL]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:storagePath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error != nil) {
            CASLog(@"Failed to create storage path: %@", error.localizedDescription);
        }
    }
}

+ (NSArray *)readQueueFromFile:(NSString *)filePath
{
    NSArray *queue = @[];
    if (@available(iOS 14.0, *)) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:filePath];
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
            queue = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storagePath];
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            CASLog(@"Failed to load events from file, error: %@", [exception callStackSymbols]);
            queue = @[];
        }
    }
    CASLog(@"%ld events read from: %@", queue.count, self.storagePath);
    return queue;
}

+ (void)migrateStorageIfNeccessary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *oldStoragePath = [self.class oldStoragePath];

    if ([fileManager fileExistsAtPath:oldStoragePath isDirectory:NULL]) {
        // Create new storage path if neccessary
        [self.class createStoragePathIfNeccessary];
        
        NSString *newStoragePath = [self.class storagePath];
        NSString *oldStorageDirectory = [self.class oldStorageDirectory];
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
    
    [self.class createStoragePathIfNeccessary];
}

+ (NSString *)oldStorageDirectory
{
    return [[self documentsDirectory] stringByAppendingString:CASEventStorageBaseFolder];
}

+ (NSString *)oldStoragePath
{
    return [[self oldStorageDirectory] stringByAppendingString:CASEventStorageFilename];
}

+ (NSString *)storageDirectory
{
    return [[self applicationSupportDirectory] stringByAppendingString:CASEventStorageBaseFolder];
}

+ (NSString *)storagePath
{
    return [[self storageDirectory] stringByAppendingString:CASEventStorageFilename];
}

+ (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

+ (NSString *)applicationSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

@end
