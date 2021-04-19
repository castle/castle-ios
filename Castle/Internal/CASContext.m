//
//  CASContext.m
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

#import <UIKit/UIKit.h>

#import "CASContext.h"
#import "CASReachability.h"
#import "Castle+Util.h"

@interface CASContext ()
@property (nonatomic, retain) NSString *clientID;
@end

@implementation CASContext

+ (instancetype)snapshotContext
{
    CASContext *context = [[CASContext alloc] init];
    context.clientID = [Castle clientId];
    return context;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    return @{ @"client_id": self.clientID };
}

@end
