//
//  CASViewController.m
//  Castle
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

#import "MainViewController.h"

#import <Castle/Castle.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (IBAction)track:(id)sender {
    [Castle track:@"Button pressed"];
}

- (IBAction)screen:(id)sender {
    [Castle screen:@"Main Screen"];
}

- (IBAction)identify:(id)sender {
    // Identify user with unique identifier including user traits
    [Castle identify:@"1245-3055" traits:@{ @"email": @"laura@example.com" }];
}

- (IBAction)testInterceptor:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // Get required header from the Castle SDK if you don't want to use the request interceptor
    [request setValue:[Castle clientId] forHTTPHeaderField:CastleClientIdHeaderName];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Response: %@, Error: %@", response, error);
    }] resume];
    
    [Castle flushIfNeeded:url];
}

- (IBAction)flush:(id)sender {
    [Castle flush];
}

- (IBAction)reset:(id)sender {
    [Castle reset];
}

@end
