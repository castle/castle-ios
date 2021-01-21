//
//  CASUtils.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/utsname.h>

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

NSString *CASDeviceModel(void)
{
#if TARGET_OS_SIMULATOR
    return [[NSProcessInfo processInfo] environment][@"SIMULATOR_MODEL_IDENTIFIER"];
#else
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString: systemInfo.machine encoding: NSUTF8StringEncoding];
#endif
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
    NSString *model = CASDeviceModel();
    NSString *system = [device systemName];
    NSString *systemVersion = [device systemVersion];
    
    return [NSString stringWithFormat:@"%@/%@ (%@) (%@; %@ %@; Castle %@)", name, version, build, model, system, systemVersion, [Castle versionString]];
}
