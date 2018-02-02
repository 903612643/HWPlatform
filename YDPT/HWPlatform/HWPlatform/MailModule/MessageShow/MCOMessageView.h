//
//  MCOMessageView.h
//  HWMail
//
//  Created by hanwei on 15/10/29.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#include <MailCore/MailCore.h>

@protocol MCOMessageViewDelegate;

@interface MCOMessageView : UIView <UIWebViewDelegate>

@property (nonatomic, strong) MCOAbstractMessage * message;
@property (nonatomic, strong) NSString* msgContent;
@property (nonatomic, weak) id <MCOMessageViewDelegate> delegate;
@property (nonatomic, assign) BOOL gestureRecognizerEnabled;

- (NSString*) getMessage;

- (void)handleTapAtpoint:(CGPoint)point;

@end

@protocol MCOMessageViewDelegate <NSObject>

@optional
- (NSData *) MCOMessageView:(MCOMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID;
- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished;

- (void) MCOMessageView:(MCOMessageView *)view handleMailtoUrlString:(NSString *)mailtoAddress;

- (void) MCOMessageView:(MCOMessageView *)view
   didTappedInlineImage:(UIImage *)inlineImage
                atPoint:(CGPoint)point
              imageRect:(CGRect)rect
              imagePath:(NSString *)path
              imageName:(NSString *)imgName
          imageMimeType:(NSString *)mimeType;

- (NSString *) MCOMessageView_templateForMainHeader:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForImage:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForAttachment:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForMessage:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForEmbeddedMessage:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForEmbeddedMessageHeader:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForAttachmentSeparator:(MCOMessageView *)view;

- (NSDictionary *) MCOMessageView:(MCOMessageView *)view templateValuesForPartWithUniqueID:(NSString *)uniqueID;
- (NSDictionary *) MCOMessageView:(MCOMessageView *)view templateValuesForHeader:(MCOMessageHeader *)header;
- (BOOL) MCOMessageView:(MCOMessageView *)view canPreviewPart:(MCOAbstractPart *)part;

- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTMLForPart:(NSString *)html;
- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTMLForMessage:(NSString *)html;
- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end
