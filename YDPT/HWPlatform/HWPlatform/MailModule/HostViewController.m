//
//  HostViewController.m
//  HWMail
//
//  Created by hanwei on 15/10/30.
//  Copyright © 2015年 HanWei. All rights reserved.
//

#import "HostViewController.h"
#import "ComposerViewController.h"
#import "HWPlatformTest-Swift.h"

@interface HostViewController ()

@end

@implementation HostViewController
//plist数据存储读写
UserDataManager * userDataManagerHost;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0/255.0 green:148/255.0 blue:255/255.0 alpha:255/255.0]];
    _myTableView = [[UITableView alloc]init];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    CGRect tableViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _myTableView.frame = tableViewFrame;
    [_BodyVIew addSubview:_myTableView];
    //添加显示数据
    [self addData];
    
    //初始化数据存储变量
    userDataManagerHost = [[UserDataManager alloc] init];
    //初始化将要显示的数据
    [self reloadDataForDisplayArray];
    NSString * StoreUserName = [userDataManagerHost.userData objectForKey:@"UserName"];
    NSString * MailLastName = [userDataManagerHost.userData objectForKey:@"MailLastName"];
    NSString *FullMailUserName = [NSString stringWithFormat:@"%@%@%@",@"账号:",StoreUserName,MailLastName];
    _SinopecLable.text = @"中石化邮箱";
    _LoginedMailAdress.text = FullMailUserName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)SetButtonOn:(id)sender {
    NSLog(@"SetButton is on");
}

//添加演示数据
-(void) addData{
/* 去掉功能组
    //写邮件功能组
    CLTreeViewNode *WriteMail = [[CLTreeViewNode alloc]init];
    WriteMail.nodeLevel = 0;
    WriteMail.type = 0;
    WriteMail.sonNodes = nil;
    WriteMail.isExpanded = FALSE;
    CLTreeView_LEVEL0_Model *WriteMail_Model =[[CLTreeView_LEVEL0_Model alloc]init];
    WriteMail_Model.name = @"写邮件";
    WriteMail_Model.headImgPath = @"writeMail.png";
    WriteMail_Model.headImgUrl = nil;
    WriteMail.nodeData = WriteMail_Model;
    
    //收件箱功能组
    CLTreeViewNode *Inbox = [[CLTreeViewNode alloc]init];
    Inbox.nodeLevel = 0;
    Inbox.type = 0;
    Inbox.sonNodes = nil;
    Inbox.isExpanded = FALSE;
    CLTreeView_LEVEL0_Model *Inbox_Model =[[CLTreeView_LEVEL0_Model alloc]init];
    Inbox_Model.name = @"收件箱";
    Inbox_Model.headImgPath = @"inbox.png";
    Inbox_Model.headImgUrl = nil;
    Inbox.nodeData = Inbox_Model;
 */
    
    //新邮件
    CLTreeViewNode *NewMail = [[CLTreeViewNode alloc]init];
    NewMail.nodeLevel = 2;
    NewMail.type = 2;
    NewMail.sonNodes = nil;
    NewMail.isExpanded = FALSE;
    CLTreeView_LEVEL2_Model *NewMailModel =[[CLTreeView_LEVEL2_Model alloc]init];
    NewMailModel.name = @"新邮件";
    NewMailModel.headImgPath = @"writeMail";
    NewMailModel.headImgUrl = nil;
    NewMail.nodeData = NewMailModel;
    
    //草稿箱
    CLTreeViewNode *Drafts = [[CLTreeViewNode alloc]init];
    Drafts.nodeLevel = 2;
    Drafts.type = 2;
    Drafts.sonNodes = nil;
    Drafts.isExpanded = FALSE;
    CLTreeView_LEVEL2_Model *DraftsModel =[[CLTreeView_LEVEL2_Model alloc]init];
    DraftsModel.name = @"草稿箱";
    DraftsModel.headImgPath = @"Drafts";
    DraftsModel.headImgUrl = nil;
    Drafts.nodeData = DraftsModel;
    
    //收件箱
    CLTreeViewNode *allMail = [[CLTreeViewNode alloc]init];
    allMail.nodeLevel = 2;
    allMail.type = 2;
    allMail.sonNodes = nil;
    allMail.isExpanded = FALSE;
    CLTreeView_LEVEL2_Model *allMailModel =[[CLTreeView_LEVEL2_Model alloc]init];
    allMailModel.name = @"收件箱";
    allMailModel.headImgPath = @"inbox";
    allMailModel.headImgUrl = nil;
    allMail.nodeData = allMailModel;

/* 去掉已读未读功能
    //未读邮件
    CLTreeViewNode *unreadMail = [[CLTreeViewNode alloc]init];
    unreadMail.nodeLevel = 2;
    unreadMail.type = 2;
    unreadMail.sonNodes = nil;
    unreadMail.isExpanded = FALSE;
    CLTreeView_LEVEL2_Model *unreadMailModl =[[CLTreeView_LEVEL2_Model alloc]init];
    unreadMailModl.name = @"未读邮件";
    unreadMailModl.headImgPath = @"unreadMail.jpg";
    unreadMailModl.headImgUrl = nil;
    unreadMail.nodeData = unreadMailModl;
    
    //已读邮件
    CLTreeViewNode *markRead = [[CLTreeViewNode alloc]init];
    markRead.nodeLevel = 2;
    markRead.type = 2;
    markRead.sonNodes = nil;
    markRead.isExpanded = FALSE;
    CLTreeView_LEVEL2_Model *markReadModel =[[CLTreeView_LEVEL2_Model alloc]init];
    markReadModel.name = @"已读邮件";
    markReadModel.headImgPath = @"markRead.jpg";
    markReadModel.headImgUrl = nil;
    markRead.nodeData = markReadModel;
 */
    
    //发件箱
    CLTreeViewNode *SendBox = [[CLTreeViewNode alloc]init];
    SendBox.nodeLevel = 2;
    SendBox.type = 2;
    SendBox.sonNodes = nil;
    SendBox.isExpanded = FALSE;
    CLTreeView_LEVEL2_Model *SendBoxModel =[[CLTreeView_LEVEL2_Model alloc]init];
    SendBoxModel.name = @"发件箱";
    SendBoxModel.headImgPath = @"SentItems";
    SendBoxModel.headImgUrl = nil;
    SendBox.nodeData = SendBoxModel;
    
    //WriteMail.sonNodes = [NSMutableArray arrayWithObjects:NewMail,Drafts,nil];
    //Inbox.sonNodes = [NSMutableArray arrayWithObjects:allMail,unreadMail,markRead,nil];
    //_dataArray = [NSMutableArray arrayWithObjects:WriteMail,Inbox, nil];
    _dataArray = [NSMutableArray arrayWithObjects:NewMail,allMail,Drafts,SendBox, nil];
}

- (IBAction)ReturnButton:(UIButton *)sender {
    //返回按钮被点中，返回主界面
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return _displayArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"level0cell";
    static NSString *indentifier1 = @"level1cell";
    static NSString *indentifier2 = @"level2cell";
    CLTreeViewNode *node = [_displayArray objectAtIndex:indexPath.row];
    
    if(node.type == 0){//类型为0的cell
        CLTreeView_LEVEL0_Cell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"Level0_Cell" owner:self options:nil] lastObject];
        }
        cell.node = node;
        [self loadDataForTreeViewCell:cell with:node];//重新给cell装载数据
        [cell setNeedsDisplay]; //重新描绘cell
        return cell;
    }
    else if(node.type == 1){//类型为1的cell
        CLTreeView_LEVEL1_Cell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier1];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"Level1_Cell" owner:self options:nil] lastObject];
        }
        cell.node = node;
        [self loadDataForTreeViewCell:cell with:node];
        [cell setNeedsDisplay];
        return cell;
    }
    else{//类型为2的cell
        CLTreeView_LEVEL2_Cell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier2];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"Level2_Cell" owner:self options:nil] lastObject];
        }
        cell.node = node;
        [self loadDataForTreeViewCell:cell with:node];
        [cell setNeedsDisplay];
        return cell;
    }
}

/*---------------------------------------
 为不同类型cell填充数据
 --------------------------------------- */
-(void) loadDataForTreeViewCell:(UITableViewCell*)cell with:(CLTreeViewNode*)node{
    if(node.type == 0){
        CLTreeView_LEVEL0_Model *nodeData = node.nodeData;
        ((CLTreeView_LEVEL0_Cell*)cell).name.text = nodeData.name;
        if(nodeData.headImgPath != nil){
            //本地图片
            [((CLTreeView_LEVEL0_Cell*)cell).imageView setImage:[UIImage imageNamed:nodeData.headImgPath]];
        }
        else if (nodeData.headImgUrl != nil){
            //加载图片，这里是同步操作。建议使用SDWebImage异步加载图片
            [((CLTreeView_LEVEL0_Cell*)cell).imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:nodeData.headImgUrl]]];
        }
    }
    
    else if(node.type == 1){
        CLTreeView_LEVEL1_Model *nodeData = node.nodeData;
        ((CLTreeView_LEVEL1_Cell*)cell).name.text = nodeData.name;
        ((CLTreeView_LEVEL1_Cell*)cell).sonCount.text = nodeData.sonCnt;
    }
    
    else{
        CLTreeView_LEVEL2_Model *nodeData = node.nodeData;
        ((CLTreeView_LEVEL2_Cell*)cell).name.text = nodeData.name;
        ((CLTreeView_LEVEL2_Cell*)cell).signture.text = nodeData.signture;
        if(nodeData.headImgPath != nil){
            //本地图片
            [((CLTreeView_LEVEL2_Cell*)cell).headImg setImage:[UIImage imageNamed:nodeData.headImgPath]];
        }
        else if (nodeData.headImgUrl != nil){
            //加载图片，这里是同步操作。建议使用SDWebImage异步加载图片
            [((CLTreeView_LEVEL2_Cell*)cell).headImg setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:nodeData.headImgUrl]]];
        }
    }
}

/*---------------------------------------
 cell高度默认为60
 --------------------------------------- */
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60;
}

/*---------------------------------------
 处理cell选中事件，需要自定义的部分
 --------------------------------------- */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CLTreeViewNode *node = [_displayArray objectAtIndex:indexPath.row];
    [self reloadDataForDisplayArrayChangeAt:indexPath.row];//修改cell的状态(关闭或打开)
    if(node.type == 2){
        //处理叶子节点选中，此处需要自定义
        CLTreeView_LEVEL2_Model *NodeDataValue = node.nodeData;
        if ([@"新邮件"  isEqual:  NodeDataValue.name])
        {
            NSLog(@"新邮件");
//            [self performSegueWithIdentifier:@"showMailComposer" sender:indexPath];
            UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
            UIViewController * next = [board instantiateViewControllerWithIdentifier:@"mailComposer"];
            [self presentViewController:next animated:true completion:nil];
        }
        else if ([@"草稿箱"  isEqual:  NodeDataValue.name])
        {
            NSLog(@"草稿箱");
            UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
            UIViewController * next = [board instantiateViewControllerWithIdentifier:@"Draft"];
            [self presentViewController:next animated:true completion:nil];
        }
        else if ([@"收件箱"  isEqual:  NodeDataValue.name])
        {
            //验证成功跳转到主界面
            UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
            UIViewController * next = [board instantiateViewControllerWithIdentifier:@"Inbox"];
            [self presentViewController:next animated:true completion:nil];
        }
        else if ([@"未读邮件"  isEqual:  NodeDataValue.name])
        {
            NSLog(@"未读邮件");
            UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
            UIViewController * next = [board instantiateViewControllerWithIdentifier:@"UnRead"];
            [self presentViewController:next animated:true completion:nil];
        }
        else if ([@"已读邮件"  isEqual:  NodeDataValue.name])
        {
            NSLog(@"已读邮件");
            UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
            UIViewController * next = [board instantiateViewControllerWithIdentifier:@"Readed"];
            [self presentViewController:next animated:true completion:nil];
        }
        else if ([@"发件箱"  isEqual:  NodeDataValue.name])
        {
            NSLog(@"发件箱");
            UIStoryboard * board = [UIStoryboard storyboardWithName:@"MailModule" bundle:nil];
            UIViewController * next = [board instantiateViewControllerWithIdentifier:@"SendItems"];
            [self presentViewController:next animated:true completion:nil];
        }
    }
    else{
        CLTreeView_LEVEL0_Cell *cell = (CLTreeView_LEVEL0_Cell*)[tableView cellForRowAtIndexPath:indexPath];
        if(cell.node.isExpanded ){
            [self rotateArrow:cell with:M_PI_2];
        }
        else{
            [self rotateArrow:cell with:0];
        }
    }
}

/*---------------------------------------
 旋转箭头图标
 --------------------------------------- */
-(void) rotateArrow:(CLTreeView_LEVEL0_Cell*) cell with:(double)degree{
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        cell.arrowView.layer.transform = CATransform3DMakeRotation(degree, 0, 0, 1);
    } completion:NULL];
}

/*---------------------------------------
 初始化将要显示的cell的数据
 --------------------------------------- */
-(void) reloadDataForDisplayArray{
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    for (CLTreeViewNode *node in _dataArray) {
        [tmp addObject:node];
        if(node.isExpanded){
            for(CLTreeViewNode *node2 in node.sonNodes){
                [tmp addObject:node2];
                if(node2.isExpanded){
                    for(CLTreeViewNode *node3 in node2.sonNodes){
                        [tmp addObject:node3];
                    }
                }
            }
        }
    }
    _displayArray = [NSArray arrayWithArray:tmp];
    [self.myTableView reloadData];
}

/*---------------------------------------
 修改cell的状态(关闭或打开)
 --------------------------------------- */
-(void) reloadDataForDisplayArrayChangeAt:(NSInteger)row{
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    NSInteger cnt=0;
    for (CLTreeViewNode *node in _dataArray) {
        [tmp addObject:node];
        if(cnt == row){
            node.isExpanded = !node.isExpanded;
        }
        ++cnt;
        if(node.isExpanded){
            for(CLTreeViewNode *node2 in node.sonNodes){
                [tmp addObject:node2];
                if(cnt == row){
                    node2.isExpanded = !node2.isExpanded;
                }
                ++cnt;
                if(node2.isExpanded){
                    for(CLTreeViewNode *node3 in node2.sonNodes){
                        [tmp addObject:node3];
                        ++cnt;
                    }
                }
            }
        }
    }
    _displayArray = [NSArray arrayWithArray:tmp];
    [self.myTableView reloadData];
}


@end
