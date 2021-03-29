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

@implementation CASContext

+ (instancetype)sharedContext
{
    static CASContext *_sharedContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedContext = [[CASContext alloc] init];
    });
    return _sharedContext;
}

#pragma mark - CASModel

- (NSDictionary *)JSONPayload
{
    NSMutableDictionary *context = [NSMutableDictionary dictionaryWithObject:[[CASDevice sharedDevice] JSONPayload] forKey:@"device"];
    
    NSLocale *locale = [NSLocale currentLocale];
    context[@"locale"] = [NSString stringWithFormat:@"%@-%@", [locale objectForKey:NSLocaleLanguageCode], [locale objectForKey:NSLocaleCountryCode]];
    
    context[@"network"] = ({
        NSMutableDictionary *network = [NSMutableDictionary dictionary];
        network[@"wifi"] = @([Castle isWifiAvailable]);
        network[@"cellular"] = @([Castle isCellularAvailable]);
        
        if([Castle isCellularAvailable]) {
            network[@"carrier"] = [Castle carrierName];
        }
        network;
    });
    
    context[@"timezone"] = [[NSTimeZone localTimeZone] name];
    
    context[@"screen"] = @{ @"width": @([UIScreen mainScreen].bounds.size.width),
                            @"height": @([UIScreen mainScreen].bounds.size.height),
                            @"density": @([UIScreen mainScreen].scale) };
    
    context[@"os"] = @{ @"name": [[UIDevice currentDevice] systemName],
                        @"version": [[UIDevice currentDevice] systemVersion] };
    
    context[@"library"] = @{ @"name": @"castle-ios",
                             @"version": [Castle versionString],
                             @"user_agent": [Castle userAgent] };
    
    return context;
}

@end
