//
//  FooterView.h
//  团购
//
//  Created by medicool on 15/2/24.
//  Copyright (c) 2015年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FooterViewDelegate <NSObject>
@optional
- (void)FooterViewClickedloadMoreData;

@end



@interface FooterView : UIView

+ (instancetype)footerView;

@property (nonatomic, weak) id<FooterViewDelegate> delegate;
@end
