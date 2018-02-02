//
//  HeaderView.m
//  ThatInbox
//
//  Created by Liyan David Chang on 8/4/13.
//  Copyright (c) 2013 Ink. All rights reserved.
//

#import "HeaderView.h"
//#import "UIColor+FlatUI.h"
#import "FPMimetype.h"
//#import "ComposerViewController.h"
//#import "UTIFunctions.h"
#import "ProgressHUD.h"


@interface HeaderView ()

//@property MCOIMAPMessage *message;
@property MCOMessageParser *message;
@property NSArray* attachments;
@end

@implementation HeaderView

- (id)initWithFrame:(CGRect)frame message:(MCOMessageParser*)message Attachments:(NSArray*)attachments{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = message;
        self.attachments = attachments;
        [self render];
    }
    return self;
}

- (UIView *)generateSpacer {
    UIView *spacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 15)];
    spacer.backgroundColor = [UIColor clearColor];
    return spacer;
}

- (UIView *)generateHR {
    UIView *hr = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    
    hr.backgroundColor = [UIColor whiteColor];
    return hr;
}

- (void)render {
    
    //[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    MCOMessageHeader *header = [self.message header];
    
    NSMutableArray *headerLabels = [[NSMutableArray alloc] init];
    NSMutableArray *AttachmentLabels = [[NSMutableArray alloc] init];
    
    NSString *fromString = [[header from] displayName] ? [[header from] displayName] : [[header from] mailbox];
    if (fromString){
        fromString = [NSString stringWithFormat:@"发件人: %@", fromString];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        label.text = fromString;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [headerLabels addObject:label];
    }
    
    if ([self displayNamesFromAddressArray:[header to]]){
        NSString *toString = [NSString stringWithFormat:@"收件人: %@", [self displayNamesFromAddressArray:[header to]]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        label.text = toString;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        label.textColor = [UIColor grayColor];
        [headerLabels addObject:label];
    }
    
    if ([self displayNamesFromAddressArray:[header cc]]){
        NSString *ccString = [NSString stringWithFormat:@"抄送: %@", [self displayNamesFromAddressArray:[header cc]] ];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        label.text = ccString;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        label.textColor = [UIColor grayColor];
        [headerLabels addObject:label];
    }
    
//    [headerLabels addObject:[self generateSpacer]];
//    [headerLabels addObject:[self generateHR]];
//    [headerLabels addObject:[self generateSpacer]];
    
    
    if ([header subject]){
        NSString *subjectString = [NSString stringWithFormat:@"主题: %@", [header subject]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        label.text = subjectString;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        [headerLabels addObject:label];
        
    }
    
    if ([header date]){
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[header date]
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterMediumStyle];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        label.text = dateString;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        label.textColor = [UIColor grayColor];
        [headerLabels addObject:label];
    }
    
//    [headerLabels addObject:[self generateSpacer]];
//    [headerLabels addObject:[self generateHR]];
    
    int tag = 0;
    if ([self.attachments count] > 0){
        [headerLabels addObject:[self generateSpacer]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        label.text = @"附件:";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        label.textColor = [UIColor grayColor];
        [headerLabels addObject:label];
    }
    
    for (int i = 0; i < self.attachments.count; i++) {
        MCOAttachment * da = [self.attachments objectAtIndex:i];
/*
        //创建按钮
        UIButton *label = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        label.frame = CGRectMake(0, 0, 300, 60);
        label.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        label.contentEdgeInsets = UIEdgeInsetsMake(10, 50, 10, 0);
        [label.titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [label setTitle:[da filename] forState:UIControlStateNormal];
        [label setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [label.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        label.tag = tag;
        tag++;
        
        //附件链接 点击事件
        [label addTarget:self action:@selector(attachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 32, 32)];
        NSString *pathToIcon = [FPMimetype iconPathForMimetype:[da mimeType] Filename:[da filename]];
        imageview.image = [UIImage imageNamed:pathToIcon];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [label addSubview:imageview];
        [headerLabels addObject:label];
        
        UIView *sp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
        sp.backgroundColor = [UIColor clearColor];
        [headerLabels addObject:sp];
 */
        //创建一个附件视图
        UIView *contentView = [[UIView alloc]initWithFrame: CGRectMake(0,0,self.frame.size.width,40)];
        [contentView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
        //创建附件图片视图
        UIImageView *AttachmentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, 32, 32)];
        NSString *pathToIcon = [FPMimetype iconPathForMimetype:[da mimeType] Filename:[da filename]];
        AttachmentImageView.image = [UIImage imageNamed:pathToIcon];
        AttachmentImageView.contentMode = UIViewContentModeScaleAspectFit;
        //创建附件名字Lable
        CGFloat LabelX = AttachmentImageView.frame.origin.x + AttachmentImageView.frame.size.width;
        //CGFloat LabelY = AttachmentImageView.frame.origin.y;
        CGFloat LabelWith = self.frame.size.width - LabelX - 110/*保存打开按钮*/ - 10/*右边距*/ - 10/*左边距*/;
        UITextView * AttachmentNameLabel = [[UITextView alloc] initWithFrame:CGRectMake(LabelX, 0, LabelWith, contentView.frame.size.height)];
        //禁止编辑
        [AttachmentNameLabel setEditable:NO];
        //AttachmentNameLabel.scrollEnabled = NO;
        AttachmentNameLabel.text = [da filename];
        [AttachmentNameLabel setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
        
        //创建打开按钮
        UIButton *OpenAttachmentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGFloat OpenButtonX = AttachmentNameLabel.frame.origin.x + AttachmentNameLabel.frame.size.width;
        CGFloat OpenButtonY = AttachmentImageView.frame.origin.y;
        OpenAttachmentButton.frame = CGRectMake(OpenButtonX, OpenButtonY, 50, 32);
        OpenAttachmentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [OpenAttachmentButton setTitle:@"打开" forState:UIControlStateNormal];
        [OpenAttachmentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [OpenAttachmentButton setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:0.8]];
        OpenAttachmentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        OpenAttachmentButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //创建保存按钮
        UIButton *SaveAttachmentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGFloat SaveButtonX = OpenAttachmentButton.frame.origin.x + OpenAttachmentButton.frame.size.width + 5/*间隔*/;
        CGFloat SaveButtonY = OpenAttachmentButton.frame.origin.y;
        SaveAttachmentButton.frame = CGRectMake(SaveButtonX, SaveButtonY, 50, 32);
        SaveAttachmentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [SaveAttachmentButton setTitle:@"保存" forState:UIControlStateNormal];
        [SaveAttachmentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [SaveAttachmentButton setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:0.8]];
        SaveAttachmentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        SaveAttachmentButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        OpenAttachmentButton.tag = tag;
        SaveAttachmentButton.tag = tag;
        tag++;
        
        //打开附件事件
        [OpenAttachmentButton addTarget:self action:@selector(OpenattachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
        //保存附件的点击事件
        [SaveAttachmentButton addTarget:self action:@selector(SaveAttachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:AttachmentImageView];
        [contentView addSubview:AttachmentNameLabel];
        [contentView addSubview:OpenAttachmentButton];
        [contentView addSubview:SaveAttachmentButton];
        
        [AttachmentLabels addObject:contentView];
    }
    
    if ([self.attachments count] > 0){
        [headerLabels addObject:[self generateHR]];
        [headerLabels addObject:[self generateSpacer]];
    }

    int startingHeight = 30;
    for (UIView *l in headerLabels){
        l.frame = CGRectMake(30, startingHeight, self.frame.size.width-60, l.frame.size.height);
        [self addSubview:l];
        startingHeight += l.frame.size.height;
    }
    for (UIView *l in AttachmentLabels){
        l.frame = CGRectMake(10, startingHeight, self.frame.size.width-20, l.frame.size.height);
        [self addSubview:l];
        startingHeight += l.frame.size.height;
    }
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, startingHeight);
    
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (NSString *)displayNamesFromAddressArray:(NSArray*)addresses {
    if ([addresses count] == 0){
        return nil;
    }
    NSMutableArray *names = [[NSMutableArray alloc] initWithArray:@[]];
    for (MCOAddress *a in addresses){
        if ([a displayName]){
            [names addObject:[a displayName]];
        } else {
            [names addObject:[a mailbox]];
        }
    }
    return [names componentsJoinedByString:@", "];
}

- (void)grabDataWithBlock: (NSData* (^)(void))dataBlock completion:(void(^)(NSData *data))callback {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        NSData *data = dataBlock();
        callback(data);
    });
}

- (void) OpenattachmentTapped:(UIButton *)button {
    
    MCOAttachment *da = [self.attachments objectAtIndex:[button tag]];
    
    NSData * attachmentData = [da data];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString * filePath = [tmpDirectory stringByAppendingString:da.filename];
    [attachmentData writeToFile:filePath atomically:YES];
    
    _docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    _docController.delegate = self;
    
    //预览存在问题，需要修改，可能是需要UIViewController
    [_docController presentOpenInMenuFromRect:button.bounds inView:button animated:YES];
    //[_docController presentPreviewAnimated:YES];
}

- (void) SaveAttachmentTapped:(UIButton *)button {
    MCOAttachment *da = [self.attachments objectAtIndex:[button tag]];
    
    NSData * attachmentData = [da data];
    NSString *StoragePath = [FCFileManager pathForDocumentsDirectory];
    StoragePath = [[StoragePath stringByAppendingString:@"/存储区域/邮箱存储区域/"] stringByAppendingString:da.filename];
    bool RtnBool = [attachmentData writeToFile:StoragePath atomically:YES];
    if (RtnBool)
    {
        [ProgressHUD showSuccess:@"保存文件成功!"];
    }
    else
    {
        [ProgressHUD showError:@"保存文件失败，请检查存储空间!"];
    }
    
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    //问题所在，应该放在UIViewController
    return self;
}

@end
