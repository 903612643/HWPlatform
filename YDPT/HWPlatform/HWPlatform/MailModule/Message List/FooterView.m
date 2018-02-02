//
//  FooterView.m
//  团购
//
//  Created by medicool on 15/2/24.
//  Copyright (c) 2015年 ZK. All rights reserved.
//

#import "FooterView.h"

@interface FooterView ()

@property (weak, nonatomic) IBOutlet UIButton *loadMoreBtn;
@property (weak, nonatomic) IBOutlet UIView *moreView;

@end

@implementation FooterView

+ (instancetype)footerView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"FooterView" owner:nil options:nil]lastObject];
}

- (IBAction)loadMoreBtnClicked:(UIButton *)sender {
    
    self.loadMoreBtn.hidden = YES;
    
    self.moreView.hidden = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(FooterViewClickedloadMoreData)]) {
            [self.delegate FooterViewClickedloadMoreData];
        }
        
        self.loadMoreBtn.hidden = NO;
        
        self.moreView.hidden = YES;
    });
    
}

@end
