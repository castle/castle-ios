//
//  CASEventStorage.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASEventStorage.h"

#import "CASUtils.h"

@implementation CASEventStorage

#pragma mark - Storage

+ (NSArray *)storedQueue
{
    NSArray *queue = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storagePath];
    CASLog(@"%ld events read from: %@", queue.count, self.storagePath);
    if (queue == nil) {
        queue = @[];
        [self persistQueue:queue];
    }
    return queue;
}

+ (void)persistQueue:(NSArray *)queue
{
    [self.class createStoragePathIfNeccessary];
    
    BOOL persisted = NO;
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:queue requiringSecureCoding:YES error:&error];
        if(data != nil && error == nil) {
            persisted = [data writeToFile:self.storagePath atomically:YES];
        }
    } else {
        persisted = [NSKeyedArchiver archiveRootObject:queue toFile:self.storagePath];
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

+ (NSString *)storageDirectory
{
    return [[self documentsDirectory] stringByAppendingString:@"/castle/"];
}

+ (NSString *)storagePath
{
    return [[self storageDirectory] stringByAppendingString:@"events"];
}

+ (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

@end
