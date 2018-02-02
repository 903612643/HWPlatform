//
//  QuickLookViewController.m
//  HWPlatformTest
//
//  Created by hanwei on 15/12/23.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import "QuickLookViewController.h"

@implementation QuickLookViewController

UINavigationController * navigationController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置导航栏颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.18 green:0.54 blue:1 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    

    [self performSelector:@selector(ShowView) withObject:nil afterDelay:0.05];
//    QLPreviewController *preview = [[QLPreviewController alloc] init];
//    preview.dataSource = self;
//    //preview.navigationItem.leftBarButtonItem
//    
//    [self.navigationController pushViewController:preview animated:YES];
}

- (IBAction)closeQuickLookAction:(id)sender {
    [navigationController dismissModalViewControllerAnimated:YES];
}

- (void)ShowView
{
//    QLPreviewController *preview = [[QLPreviewController alloc] init];
//    preview.dataSource = self;
//    [self.navigationController showViewController:preview sender:self];
    
    QLPreviewController *ql = [[QLPreviewController alloc] init];
    ql.navigationController.navigationBarHidden = YES;
    // Set data source
    ql.dataSource = self;
    
    // Which item to preview
    [ql setCurrentPreviewItemIndex:0];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:ql];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(closeQuickLookAction:)];
    ql.navigationItem.leftBarButtonItem = backButton;
    
    // Push new viewcontroller, previewing the document
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction) closeWindow:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - QuickLook

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
    
    return YES;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
    
    NSLog(@"%@", _path);
    return [NSURL fileURLWithPath:_path];
}

@end
