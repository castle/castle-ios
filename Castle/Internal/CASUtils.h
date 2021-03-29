//
//  CASUtils.h
//  Castle
//
//  Copyright © 2017 Castle. All rights reserved.
//

#import <Foundation/Foundation.h>

// Logging
void CASEnableDebugLogging(BOOL enabled);
void CASLog(NSString *format, ...);

// User Agent
NSString *CASUserAgent(void);
