//
//  FBFilesTableViewController.m
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import "FBFilesTableViewController.h"
#import "FBCustomPreviewController.h"
#import "FCFileManager.h"

@interface FBFilesTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *FileListTableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *Navigationitem;

@end

@implementation FBFilesTableViewController

/*
- (id)initWithPath:(NSString *)path
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
		self.path = path;
		
		self.title = [path lastPathComponent];
		
		NSError *error = nil;
		NSArray *tempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
		
		if (error)
		{
			NSLog(@"ERROR: %@", error);
			
			if ([path isEqualToString:@"/System"])
				tempFiles = @[@"Library"];
			
			if ([path isEqualToString:@"/Library"])
				tempFiles = @[@"Preferences"];
			
			if ([path isEqualToString:@"/var"])
				tempFiles = @[@"mobile"];
			
			if ([path isEqualToString:@"/usr"])
				tempFiles = @[@"lib", @"libexec", @"bin"];
		}
		
		self.files = [tempFiles sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString* file1, NSString* file2) {
			NSString *newPath1 = [self.path stringByAppendingPathComponent:file1];
			NSString *newPath2 = [self.path stringByAppendingPathComponent:file2];

			BOOL isDirectory1, isDirectory2;
			[[NSFileManager defaultManager ] fileExistsAtPath:newPath1 isDirectory:&isDirectory1];
			[[NSFileManager defaultManager ] fileExistsAtPath:newPath2 isDirectory:&isDirectory2];
			
			if (isDirectory1 && !isDirectory2)
				return NSOrderedDescending;
			
			return  NSOrderedAscending;
		}];
    }
    return self;
}
*/

- (void)initPath:(NSString *)path SelectFunction:(NSString*)function
{
    self.path = path;
    self.SelectFunction = function;
    
    self.title = [path lastPathComponent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置导航栏颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.18 green:0.54 blue:1 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    

    //文档管理主页添加功能按钮
    if ([self.SelectFunction isEqualToString:@"FileManager"])
    {
        //子目录添加附件功能
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(AddEditBtnPressed:)];
    }
    
    //允许编辑的时候多选
    //self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    NSError *error = nil;
    NSArray *tempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:&error];
    if (error)
    {
        NSLog(@"ERROR: %@", error);
        
        if ([_path isEqualToString:@"/System"])
            tempFiles = @[@"Library"];
        
        if ([_path isEqualToString:@"/Library"])
            tempFiles = @[@"Preferences"];
        
        if ([_path isEqualToString:@"/var"])
            tempFiles = @[@"mobile"];
        
        if ([_path isEqualToString:@"/usr"])
            tempFiles = @[@"lib", @"libexec", @"bin"];
    }
    
    self.files = [[tempFiles sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString* file1, NSString* file2) {
        NSString *newPath1 = [self.path stringByAppendingPathComponent:file1];
        NSString *newPath2 = [self.path stringByAppendingPathComponent:file2];
        
        BOOL isDirectory1, isDirectory2;
        [[NSFileManager defaultManager ] fileExistsAtPath:newPath1 isDirectory:&isDirectory1];
        [[NSFileManager defaultManager ] fileExistsAtPath:newPath2 isDirectory:&isDirectory2];
        
        if (isDirectory1 && !isDirectory2)
            return NSOrderedDescending;
        
        return  NSOrderedAscending;
    }] mutableCopy];
}


- (IBAction)AddEditBtnPressed:(UIButton *)sender{
    NSLog(@"添加编辑按钮选中!!!");
    
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem.title = @"确定";
    [self.navigationItem.rightBarButtonItem setAction:@selector(EditOKBtnPressed:)];
}

- (IBAction)EditOKBtnPressed:(UIButton *)sender{
    NSLog(@"编辑确定按钮选中!!!");

/*
    //一定要在setEditing:NO之前调用，否则无数据
    NSArray *selectArr = [self.tableView indexPathsForSelectedRows];
    NSMutableDictionary * FilePaths = [[NSMutableDictionary alloc] init];
    for (NSIndexPath *indexPath in selectArr) {
        NSString * FileName = self.files[indexPath.row];
        NSString *FilePath = [self.path stringByAppendingPathComponent:FileName];
        //NSURL*FilePathURL =  [NSURL fileURLWithPath:FilePath];
        
        [FilePaths setObject:FilePath forKey:FileName];
    }
    
    //委托调用...传递回写邮件界面
    [_delegate FinishAddAttachment:FilePaths];
*/
 
    [self.tableView setEditing:NO animated:YES];
    
    self.navigationItem.rightBarButtonItem.title = @"编辑";
    [self.navigationItem.rightBarButtonItem setAction:@selector(AddEditBtnPressed:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) closeWindow:(id)sender {

    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
	
	BOOL isDirectory;
	[[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
	
    cell.textLabel.text = self.files[indexPath.row];
	
	if (isDirectory)
		cell.imageView.image = [UIImage imageNamed:@"Folder"];
	else if ([[newPath pathExtension] isEqualToString:@"png"])
		cell.imageView.image = [UIImage imageNamed:@"Picture"];
	else
		cell.imageView.image = nil;
	
#if 0
	if (fileExists && !isDirectory)
		cell.accessoryType = UITableViewCellAccessoryDetailButton;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
#endif
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
	
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:newPath.lastPathComponent];
	
	NSError *error = nil;
	
	[[NSFileManager defaultManager] copyItemAtPath:newPath toPath:tmpPath error:&error];
	
	if (error)
		NSLog(@"ERROR: %@", error);
	
	UIActivityViewController *shareActivity = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:tmpPath]] applicationActivities:nil];
	
	shareActivity.completionHandler = ^(NSString *activityType, BOOL completed){
		[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
		
	};
	
	UIViewController *vc = [[UIViewController alloc] init];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
	nc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	
	[self.navigationController presentViewController:nc animated:YES completion:^{
		
	}];
}

//选中行的时候
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.isEditing == YES) {
        //编辑状态
    } else {
        //非编辑状态
        //[tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
        
        
        BOOL isDirectory;
        BOOL fileExists = [[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
        
        
        if (fileExists)
        {
            if (isDirectory)
            {
                
                FBFilesTableViewController *vc = [[FBFilesTableViewController alloc] init];
                [vc initPath:newPath SelectFunction:self.SelectFunction];
                vc.delegate = self.delegate;
/*
                 //子目录增加功能按钮
                 if ([self.SelectFunction isEqualToString:@"FileManager"])
                 {
                     //添加编辑功能
                     vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(AddEditBtnPressed:)];
                 }
 */

                 
                 [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([FBCustomPreviewController canHandleExtension:[newPath pathExtension]])
            {
                FBCustomPreviewController *preview = [[FBCustomPreviewController alloc] initWithFile:newPath];
                
                //			UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:preview];
                //			[self.navigationController showDetailViewController:detailNavController sender:self];
                [self.navigationController showViewController:preview sender:self];
            }
            else
            {
                if ([self.SelectFunction isEqualToString:@"AddAttachment"])
                {
                    //添加附件不进行预览
                    NSMutableDictionary * FilePaths = [[NSMutableDictionary alloc] init];
                    NSString *FileName = self.files[self.tableView.indexPathForSelectedRow.row];
                    NSString *FilePath = [self.path stringByAppendingPathComponent:FileName];
                    NSLog(@"%@", FilePath);
                    [FilePaths setObject:FilePath forKey:FileName];
                    
                    //委托调用...传递回写邮件界面
                    [_delegate FinishAddAttachment:FilePaths];
                    
                    //退出当前界面
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }
                else
                {
                    //非添加附件，点击预览
                    QLPreviewController *preview = [[QLPreviewController alloc] init];
                    preview.dataSource = self;
                    
                    //			UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:preview];
                    //			[self.navigationController showDetailViewController:detailNavController sender:self];
                    
                    [self.navigationController showViewController:preview sender:self];
                }
            }
        }
    }
}

//反选行的时候
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing == YES) {
        
    } else {
        
    }
}

//实现删除功能
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 删除沙盒中的文件
    NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
    [FCFileManager removeItemAtPath:newPath];
    
    // 从数据源中删除
    [self.files removeObjectAtIndex:indexPath.row];
    
    // 从列表中删除
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - QuickLook

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
	
    return YES;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
	
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[self.tableView.indexPathForSelectedRow.row]];
	
    return [NSURL fileURLWithPath:newPath];
}

@end
