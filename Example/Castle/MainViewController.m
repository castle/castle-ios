//
//  MainViewController.m
//  Castle
//
//  Copyright (c) 2017 Castle. All rights reserved.
//

#import "MainViewController.h"

#import <Castle/Castle.h>
#import <Castle/CASEventStorage.h>

#import "DemoViewController.h"

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UILabel *queueCountLabel;
@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateQueueCountLabel];
}

- (IBAction)screen:(id)sender {
    [Castle screen:@"Main Screen"];
    [self updateQueueCountLabel];
}

- (IBAction)identify:(id)sender {
    // Identify user with unique identifier including user traits
    [Castle identify:@"1245-3055" traits:@{ @"email": @"laura@example.com" }];
    [self updateQueueCountLabel];
}

- (IBAction)testInterceptor:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // Get required header from the Castle SDK if you don't want to use the request interceptor
    [request setValue:[Castle clientId] forHTTPHeaderField:CastleClientIdHeaderName];
    
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
