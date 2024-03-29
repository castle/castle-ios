//
//  MainViewController.m
//  Castle
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

#import "MainViewController.h"

@import AppTrackingTransparency;

#import <Castle/Castle.h>
#import <Castle/CASEventStorage.h>

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UILabel *queueCountLabel;
@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateQueueCountLabel];
    
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        NSLog(@"AppTrackingTransparency status: %lu", status);
    }];
}

- (IBAction)screen:(id)sender {
    [Castle screenWithName:@"Main Screen"];
    [self updateQueueCountLabel];
}

- (IBAction)custom:(id)sender {
    [Castle customWithName:@"Custom" properties:@{ @"customKey": @"value" }];
    [self updateQueueCountLabel];
}

- (IBAction)identify:(id)sender {
    // Identify user with unique identifier including user traits
    [Castle setUserJwt:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImVjMjQ0ZjMwLTM0MzItNGJiYy04OGYxLTFlM2ZjMDFiYzFmZSIsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsInJlZ2lzdGVyZWRfYXQiOiIyMDIyLTAxLTAxVDA5OjA2OjE0LjgwM1oifQ.eAwehcXZDBBrJClaE0bkO9XAr4U3vqKUpyZ-d3SxnH0"];
    [self updateQueueCountLabel];
}

- (IBAction)testInterceptor:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // Get required header from the Castle SDK if you don't want to use the request interceptor
    [request setValue:[Castle createRequestToken] forHTTPHeaderField:CastleRequestTokenHeaderName];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Response: %@, Error: %@", response, error);
    }] resume];
    
    [Castle flushIfNeeded:url];
    [self updateQueueCountLabel];
}

- (IBAction)flush:(id)sender {
    [Castle flush];
    [self updateQueueCountLabel];
}

- (IBAction)reset:(id)sender {
    [Castle reset];
    [self updateQueueCountLabel];
}

- (IBAction)pushViewController:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"main"];
    controller.title = [NSString stringWithFormat:@"View Controller %ld", self.navigationController.viewControllers.count];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)pushEmbeddedViewController:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"embedded"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private

- (void)updateQueueCountLabel {
    self.queueCountLabel.text = [NSString stringWithFormat:@"Queue size: %ld", [CASEventStorage storedQueue].count];
}

@end
