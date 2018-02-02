//
//  HostViewController.h
//  HWMail
//
//  Created by hanwei on 15/10/30.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLTree.h"

@interface HostViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

//已登录账户邮箱地址
@property (weak, nonatomic) IBOutlet UILabel *LoginedMailAdress;
//功能导航View
@property (weak, nonatomic) IBOutlet UIView *BodyVIew;
@property (weak, nonatomic) IBOutlet UILabel *SinopecLable;
@property (strong,nonatomic) UITableView* myTableView;
@property(strong,nonatomic) NSMutableArray* dataArray; //保存全部数据的数组
@property(strong,nonatomic) NSArray *displayArray;   //保存要显示在界面上的数据的数组

@end
