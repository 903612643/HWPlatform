//
//  QuickLookViewController.h
//  HWPlatformTest
//
//  Created by hanwei on 15/12/23.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface QuickLookViewController : UIViewController <QLPreviewControllerDataSource>

@property (nonatomic, copy) NSString *path;

@end
