//
//  DemoViewController.m
//  Castle
//
//  Copyright © 2020 Castle. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (IBAction)push:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DemoViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"viewcontroller"];
    controller.title = [NSString stringWithFormat:@"View Controller %ld", self.navigationController.viewControllers.count];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
