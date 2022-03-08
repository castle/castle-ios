//
//  CASUserJwt.m
//  Castle
//
//  Created by Alexander Simson on 2022-03-08.
//

#import "CASUserJwt.h"
#import "CASUtils.h"

@interface CASUserJwt ()
@property (nonatomic, copy, readwrite) NSString * _Nonnull jwt;
@end

@implementation CASUserJwt

#pragma mark - Factory

+ (_Nullable instancetype)userWithJwt:(NSString * _Nonnull)jwt
{
    if(!jwt) {
        CASLog(@"User jwt can't be nil.");
        return nil;
    }
    
    if(jwt.length == 0) {
        CASLog(@"User jwt can't be empty.");
        return nil;
    }
    
    CASUserJwt *model = [[CASUserJwt alloc] init];
    model.jwt = jwt;
    return model;
}

#pragma mark - CASModel

- (id)JSONPayload
{
    return @{
        @"jwt": self.jwt
    };
}


@end
