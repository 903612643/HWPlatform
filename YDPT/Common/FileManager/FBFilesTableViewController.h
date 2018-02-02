//
//  FBFilesTableViewController.h
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@protocol DFFileManagerDelegate <NSObject>

-(void)FinishAddAttachment:(NSDictionary *)theAttachmentFiles;

@end

@interface FBFilesTableViewController : UITableViewController <QLPreviewControllerDataSource>

- (void)initPath:(NSString *)path SelectFunction:(NSString*)function;

@property(weak,nonatomic)id<DFFileManagerDelegate> delegate;
@property (strong) NSString *path;
@property (strong) NSString *SelectFunction;
@property (strong) NSMutableArray *files;

@end
