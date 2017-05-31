//
//  CASUtils.m
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import "CASUtils.h"

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
        format = [NSString stringWithFormat:@"[CASSTLE] %@", format];
        NSLogv(format, args);
        va_end(args);
    }
}
