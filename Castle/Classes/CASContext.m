//
//  CASContext.m
//  Castle
//
//  Created by Alexander Simson on 2018-02-12.
//

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

- (id)JSONPayload
{
    NSMutableDictionary *context = [NSMutableDictionary dictionaryWithObject:[[CASDevice sharedDevice] JSONPayload] forKey:@"device"];
    
    context[@"timezone"] = [NSTimeZone systemTimeZone].name;
    
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
    
    context[@"library"] = @{ @"name": @"Castle iOS",
                             @"version": [Castle versionString] };
    
    return context;
}

@end
