//
//  CASUtils.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASUtils.h"

#import "Castle.h"

static BOOL CastleDebugLoggingEnabled = NO;

void CASEnableDebugLogging(BOOL enabled)
{
    CastleDebugLoggingEnabled = enabled;
}

void CASLog(NSString *format, ...)
{
    if(CastleDebugLoggingEnabled) {
        va_list args;
        va_start(args, format);
        format = [NSString stringWithFormat:@"[CASTLE] %@", format];
        NSLogv(format, args);
        va_end(args);
    }
}

NSString *CASUserAgent(void)
{
    // Get host app version information from the main bundle
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    // Gather device information
    UIDevice *device = [UIDevice currentDevice];
    NSString *model = [device model];
    NSString *system = [device systemName];
    NSString *systemVersion = [device systemVersion];
    
    return [NSString stringWithFormat:@"%@/%@ (%@) (%@; %@ %@; Castle %@)", name, version, build, model, system, systemVersion, [Castle versionString]];
}
