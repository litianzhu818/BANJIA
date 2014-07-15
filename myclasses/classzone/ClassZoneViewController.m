//
//  ClassZoneViewController.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ClassZoneViewController.h"
#import "XDTabViewController.h"
#import "AddDongTaiViewController.h"
#import "HeaderCell.h"
#import "XDTabViewController.h"
#import "TrendsCell.h"
#import "DongTaiDetailViewController.h"
#import "ChooseClassInfoViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "NewDiariesViewController.h"

#import "EGORefreshTableHeaderView.h"
#import "FooterView.h"

#import "PersonalSettingCell.h"

#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "InputTableBar.h"
#import "DiaryTools.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  10000
#define RowTag     100

#define ImageHeight  65.5f

#define ImageCountPerRow  4

@interface ClassZoneViewController ()<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
NewDongtaiDelegate,
ClassZoneDelegate,
EGORefreshTableHeaderDelegate,
DongTaiDetailAddCommentDelegate,
EGORefreshTableDelegate,
UIActionSheetDelegate,
ReturnFunctionDelegate,
NameButtonDel>
{
    UITableView *classZoneTableView;
    NSMutableArray *DongTaiArray;
    NSMutableArray *tmpArray;
    NSMutableDictionary *tmpDict;
    NSString *page;
    NSString *monthStr;
    CGFloat bgImageViewHeight;
    
    UIImageView *bgImageView;
    
    BOOL isRefresh;
    
    UILabel *noneDongTaiLabel;
    
    BOOL haveNew;
    
    int uncheckedCount;
    
    EGORefreshTableHeaderView *pullRefreshView;
    FooterView *footerView;
    BOOL _reloading;
    
    UIButton *addButton;
    
    OperatDB *db;
    
    NSDictionary *waitTransmitDict;
    NSDictionary *waitCommentDict;
    
    NSString *className;
    NSString *classID;
    NSString *schoolID;
    NSString *schoolName;
    NSString *classTopImage;
    
    InputTableBar *inputTabBar;
    CGFloat tmpheight;
    CGSize inputSize;
    CGFloat faceViewHeight;
    
    UITapGestureRecognizer *backTgr;
    NSString *settingCacheString;
}
@end

@implementation ClassZoneViewController
@synthesize fromClasses,fromMsg,refreshDel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolID = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolid"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classTopImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"classtopimage"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClassInfo) name:@"changeClassInfo" object:nil];
    
    self.titleLabel.text = @"班级空间";
    monthStr = @"";
    
    db = [[OperatDB alloc] init];
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    page = @"";
    haveNew = NO;
    _reloading = NO;
    
    bgImageViewHeight = 150.0f;
    uncheckedCount = 0;
    
    self.stateView.hidden = YES;
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    DongTaiArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    addButton.hidden = YES;
    [addButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [addButton setTitle:@"发布" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addDongTaiClick) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue] == 1)
        {
            [self.navigationBarView addSubview:addButton];
        }
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue] == 1)
        {
            [self.navigationBarView addSubview:addButton];
        }
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"teachers"])
    {
        [self.navigationBarView addSubview:addButton];
    }
    
    
    noneDongTaiLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, bgImageViewHeight+76, SCREEN_WIDTH-40, 60)];
    noneDongTaiLabel.text = @"这个班级还没有任何动态，你可以成为第一人发布动态的人哦！";
    noneDongTaiLabel.numberOfLines = 2;
    noneDongTaiLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noneDongTaiLabel.hidden = YES;
    noneDongTaiLabel.textColor = TITLE_COLOR;
    noneDongTaiLabel.textAlignment = NSTextAlignmentCenter;
    noneDongTaiLabel.backgroundColor = [UIColor clearColor];
    
    classZoneTableView = [[UITableView alloc] init];
    if (fromClasses)
    {
        classZoneTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT);
    }
    else
    {
        classZoneTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT);
    }
    
    classZoneTableView.delegate = self;
    classZoneTableView.dataSource = self;
    classZoneTableView.tag = 10000;
    classZoneTableView.backgroundColor = self.bgView.backgroundColor;
//    classZoneTableView.backgroundColor = RGB(205, 205, 205, 1);
    classZoneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    classZoneTableView.showsVerticalScrollIndicator = NO;
    [self.bgView addSubview:classZoneTableView];
    
    [classZoneTableView addSubview:noneDongTaiLabel];
    
    if (!fromClasses)
    {
        addButton.hidden = NO;
    }
    if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"]) &&
       ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue]== 2))
    {
        addButton.hidden = YES;
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"]) &&
            ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue]== 2))
    {
        addButton.hidden = YES;
    }
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classZoneTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    if ([Tools NetworkReachable])
    {
        addButton.hidden = YES;
        [self getCacheSetting];
        [self getCLassSettings];
    }
    else
    {
        [self getCacheSetting];
    }
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor grayColor];
    inputTabBar.returnFunDel = self;
    inputTabBar.notOnlyFace = NO;
    [self.bgView addSubview:inputTabBar];
    inputSize = CGSizeMake(250, 30);
    [inputTabBar setLayout];
    
    backTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backInput)];
}

-(void)backInput
{
    [classZoneTableView removeGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        [inputTabBar.inputTextView resignFirstResponder];
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, inputSize.height+10);
    }];
}

-(void)myReturnFunction
{
    DDLOG(@"input text %@",inputTabBar.inputTextView.text);
    if ([[inputTabBar analyString:inputTabBar.inputTextView.text] length] <= 0)
    {
        [Tools showAlertView:@"请输入评论内容！" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[waitCommentDict objectForKey:@"_id"],
                                                                      @"c_id":classID,
                                                                      @"content":[inputTabBar analyString:inputTabBar.inputTextView.text]
                                                                      } API:COMMENT_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                page = @"";
                monthStr = @"";
                [self getDongTaiList];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
    inputSize = CGSizeMake(250, 30);
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
    }];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.refreshDel = nil;
    
    inputTabBar.returnFunDel = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    inputTabBar.returnFunDel = self;
    inputSize = CGSizeMake(250, 30);
//    [UIView animateWithDuration:0.2 animations:^{
//        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
//    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeClassInfo
{
    [classZoneTableView reloadData];
}

-(void)unShowSelfViewController
{
    if (fromClasses)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setObject:NOTFROMCLASS forKey:FROMWHERE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - headerdelegate
-(void)refreshAction
{
    [self getDongTaiList];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    if (fromClasses)
    {
        [Tools showAlertView:@"您还没有进入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    page = @"";
    monthStr = @"";
    [self getCLassSettings];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    if (fromClasses)
    {
        [Tools showAlertView:@"您还没有进入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    [self getMoreDongTai];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullRefreshView egoRefreshScrollViewDidScroll:classZoneTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:classZoneTableView];
    }
    [self backInput];
    [inputTabBar backKeyBoard];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:classZoneTableView];
    [footerView egoRefreshScrollViewDidEndDragging:classZoneTableView];
}

#pragma mark - classzoneDelegate
-(void)haveAddDonfTai:(BOOL)add
{
    if (add)
    {
        haveNew = YES;
        page = @"";
        monthStr = @"";
        [self getDongTaiList];
    }
}

#pragma mark - applyJoin
-(void)applyJoin
{
    ChooseClassInfoViewController *chooseClassInfo = [[ChooseClassInfoViewController alloc] init];
    chooseClassInfo.classID = classID;
    chooseClassInfo.className = className;
    chooseClassInfo.schoolName = schoolName;
    chooseClassInfo.schoolID = schoolID;
    [self.navigationController pushViewController:chooseClassInfo animated:YES];
}
-(void)addDongTaiClick
{
    AddDongTaiViewController *addDongTaiViewController = [[AddDongTaiViewController alloc] init];
    addDongTaiViewController.classID = classID;
    addDongTaiViewController.fromCLass = YES;
    addDongTaiViewController.classZoneDelegate = self;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:addDongTaiViewController animated:YES];
}

-(void)getCLassSettings
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:GETSETTING];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classsetting dict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
                NSString *key = [requestUrlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                [self dealClassSetting:responseDict];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            _reloading = NO;
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
-(void)getCacheSetting
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    settingCacheString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *settingCacheDict = [Tools JSonFromString:settingCacheString];
    if ([settingCacheDict count] > 0)
    {
        [self dealClassSetting:settingCacheDict];
    }
}

-(void)dealClassSetting:(NSDictionary *)responseDict
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"set"] forKey:@"set"];
    
    [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"role"] forKey:@"role"];
    [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"admin"] forKey:@"admin"];
    if (![[[responseDict objectForKey:@"data"] objectForKey:@"opt"] isEqual:[NSNull null]])
    {
        if ([[[responseDict objectForKey:@"data"] objectForKey:@"opt"] count] > 0)
        {
            [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"opt"] forKey:@"opt"];
        }
    }
    
    [ud synchronize];
    
    if ([self isInAccessTime])
    {
        addButton.hidden = NO;
        if ([Tools NetworkReachable])
        {
            [self getCacheData];
            [self getDongTaiList];
        }
        else
        {
            [self getCacheData];
        }
    }
    else
    {
        [tmpArray removeAllObjects];
        [classZoneTableView reloadData];
        addButton.hidden = YES;
    }
    
    if (fromClasses)
    {
        addButton.hidden = YES;
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (fromClasses)
    {
        return [tmpArray count]>0?2:1;
    }
    else
    {
        return [tmpArray count]+1;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 0)
    {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
        
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.backgroundColor = UIColorFromRGB(0xf1f0ec);
        headerLabel.textColor = TITLE_COLOR;
        
        UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(34.75, 0, 1.5, 40)];
        verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
        [headerView addSubview:verticalLineView];
        
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(28, 12.5, 15, 15)];
        dotView.layer.cornerRadius = 7.5;
        dotView.clipsToBounds = YES;
        dotView.layer.borderColor = [UIColor whiteColor].CGColor;
        dotView.layer.borderWidth = 1.5;
        dotView.backgroundColor = RGB(64, 196, 110, 1);
        [headerView addSubview:dotView];
        NSDictionary *groupDict = [tmpArray objectAtIndex:section-1];
        headerLabel.text = [groupDict objectForKey:@"date"];
        headerLabel.frame = CGRectMake(50, 5, SCREEN_WIDTH, 30);
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section > 0)
    {
        return 40;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (fromClasses)
    {
        if(section == 0)
        {
            return 1;
        }
        else if(([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 1))
        {
            if ([tmpArray count] > 0)
            {
                noneDongTaiLabel.hidden = YES;
            }
            else
            {
                noneDongTaiLabel.hidden = NO;
            }
            
            NSDictionary *dict = [tmpArray objectAtIndex:section-1];
            NSArray *array = [dict objectForKey:@"diaries"];
            return [array count];
        }
    }
    else
    {
        if (section >0)
        {
            if ([tmpArray count] > 0)
            {
                noneDongTaiLabel.hidden = YES;
            }
            else
            {
                noneDongTaiLabel.hidden = NO;
            }
            
            NSDictionary *dict = [tmpArray objectAtIndex:section-1];
            NSArray *array = [dict objectForKey:@"diaries"];
            return [array count];
        }
        else
            return 2;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat he=0;
    if (SYSVERSION>=7)
    {
        he = 5;
    }
    if (indexPath.section >0)
    {
        if (indexPath.section < [tmpArray count])
        {
            
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            NSDictionary *dict = [array objectAtIndex:indexPath.row];
            
            return [DiaryTools heightWithDiaryDict:dict andShowAll:NO];
        }
        else
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            if (indexPath.row < [array count])
            {
                NSDictionary *dict = [array objectAtIndex:indexPath.row];
                
                return [DiaryTools heightWithDiaryDict:dict andShowAll:NO];;
            }
            else
            {
                return 40;
            }
        }
        
    }
    else if(indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            if (fromClasses)
            {
                return bgImageViewHeight+72.5;
            }
            return bgImageViewHeight;
        }
        else if (uncheckedCount > 0)
        {
            return 30;
        }
    }
    return 0;
}

-(void)nameButtonClick:(NSDictionary *)dict
{
//    DDLOG(@"person dict %@",dict);
//    PersonDetailViewController *personDetailVC = [[PersonDetailViewController alloc] init];
//    personDetailVC.personName = [[dict objectForKey:@"by"] objectForKey:@"name"];
//    personDetailVC.personID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
//    [self.sideMenuController hideMenuAnimated:YES];
//    [self.navigationController pushViewController:personDetailVC animated:YES];
    
    DDLOG(@"home %@",dict);
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.fromclass = NO;
    dongtaiDetailViewController.addComDel = self;
    [[NSUserDefaults standardUserDefaults] setObject:classID forKey:@"classid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dongtaiDetailViewController.addComDel = self;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

-(void)cellCommentDiary:(NSDictionary *)dict
{
    waitCommentDict = dict;
    [inputTabBar.inputTextView becomeFirstResponder];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *headeViewCell = @"headerViewCell";
            TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:headeViewCell];
            if (cell == nil)
            {
                cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headeViewCell];
            }
            cell.headerImageView.hidden = NO;
            cell.nameLabel.hidden = NO;
            cell.locationLabel.hidden = NO;
            cell.topImageView.hidden = NO;
            cell.nameButtonDel = self;
            
            cell.topImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight);
            NSString *topurlstring = [[NSUserDefaults standardUserDefaults] objectForKey:@"classkbimage"];
            if ([topurlstring length] >10)
            {
                [Tools fillImageView:cell.topImageView withImageFromURL:topurlstring andDefault:@"toppic"];
            }
            else
            {
                UIImage *topImage = [UIImage imageNamed:@"toppic"];
                cell.topImageView.image = topImage;
            }
            
            cell.headerImageView.frame = CGRectMake(10, 84.5, 53, 53);
            cell.headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.headerImageView.layer.borderWidth = 2;
            
            
            UIView *verticalLineView = [[UIView alloc] init];
            verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
            verticalLineView.frame = CGRectMake(34.75, cell.headerImageView.frame.size.height+cell.headerImageView.frame.origin.y, 1.5, 12.5);
            [cell.bgView addSubview:verticalLineView];
            
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if (![[ud objectForKey:@"classiconimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classiconimage"] length] > 10)
            {
                [Tools fillImageView:cell.headerImageView withImageFromURL:[ud objectForKey:@"classiconimage"] andDefault:@"headpic.jpg"];
            }
            else
            {
                [cell.headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
            }
            
            
            cell.locationLabel.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x+7, cell.headerImageView.frame.origin.y+5, 190, 20);
            cell.locationLabel.font = [UIFont systemFontOfSize:18];
            cell.locationLabel.shadowColor = TITLE_COLOR;
            cell.locationLabel.shadowOffset = CGSizeMake(0.5, 0.5);
            cell.locationLabel.textAlignment = NSTextAlignmentLeft;
            cell.locationLabel.textColor = [UIColor whiteColor];
            cell.locationLabel.layer.shadowColor = [UIColor grayColor].CGColor;
            cell.locationLabel.layer.shadowOffset = CGSizeMake(5, 5);

            
            cell.nameLabel.textAlignment = NSTextAlignmentLeft;
            cell.nameLabel.frame = CGRectMake(cell.headerImageView.frame.size.width+cell.headerImageView.frame.origin.x+7, cell.headerImageView.frame.origin.y+30, 190, 20);
            cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
            cell.nameLabel.shadowColor = TITLE_COLOR;
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            cell.nameLabel.textColor = [UIColor whiteColor];
            cell.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            cell.nameLabel.layer.shadowColor = TITLE_COLOR.CGColor;
            cell.nameLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
            
            if(SYSVERSION < 7)
            {
                cell.nameLabel.backgroundColor = [UIColor clearColor];
                cell.locationLabel.backgroundColor = [UIColor clearColor];
            }
            cell.locationLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
            cell.backgroundColor = [UIColor clearColor];
            if (fromClasses)
            {
                cell.praiseButton.hidden = NO;
                cell.praiseButton.frame = CGRectMake(35, bgImageViewHeight+18, SCREEN_WIDTH-70, 42);
                [cell.praiseButton setTitle:@"申请加入" forState:UIControlStateNormal];
                [cell.praiseButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
                [cell.praiseButton addTarget:self action:@selector(applyJoin) forControlEvents:UIControlEventTouchUpInside];
                cell.praiseButton.titleLabel.font = [UIFont systemFontOfSize:18];
                [cell.praiseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cell.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight+72.5);
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
        else if (indexPath.row == 1)
        {
            static NSString *newDiary = @"newdiary";
            UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:newDiary];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newDiary];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.text = [NSString stringWithFormat:@"有%d条待审核日志",uncheckedCount];
            if (uncheckedCount > 0)
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
    }
    else if(indexPath.section > 0)
    {
        
        static NSString *topImageView = @"trendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
        
        cell.nameButtonDel = self;
        
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [array objectAtIndex:indexPath.row];
        cell.diaryDetailDict = dict;
        NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        NSString *nameStr = name;
        
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        cell.locationLabel.hidden = NO;
        cell.praiseButton.hidden = NO;
        cell.commentButton.hidden = NO;
        cell.transmitButton.hidden = NO;
        
        cell.commentsTableView.frame = CGRectMake(0, 0, 0, 0);
        
        cell.nameLabel.frame = CGRectMake(60, 5, [nameStr length]*18>170?170:([nameStr length]*18), 25);
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = NAMEFONT;
        cell.nameLabel.textColor = NAMECOLOR;
        
        NSString *timeStr = [Tools showTimeOfToday:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        NSString *c_name = [dict objectForKey:@"c_name"];
        cell.timeLabel.text = c_name;
        cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH-[c_name length]*18-20, 2, [c_name length]*18, 35);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.numberOfLines = 2;
        cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        cell.headerImageView.backgroundColor = [UIColor clearColor];
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERBG];
        cell.locationLabel.frame = CGRectMake(60, cell.headerImageView.frame.origin.y+cell.headerImageView.frame.size.height-LOCATIONLABELHEI, SCREEN_WIDTH-80, LOCATIONLABELHEI);
        cell.locationLabel.text = [NSString stringWithFormat:@"于%@在%@",timeStr,[[dict objectForKey:@"detail"] objectForKey:@"add"]];
        cell.locationLabel.numberOfLines = 1;
        cell.locationLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        
        cell.contentLabel.hidden = YES;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        
        for(UIView *v in cell.imagesView.subviews)
        {
            if ([v isKindOfClass:[UIImageView class]])
            {
                [v removeFromSuperview];
            }
        }
        if (![[[dict objectForKey:@"detail"] objectForKey:@"content"] length] <=0)
        {
            CGFloat he = 0;
            if (SYSVERSION >= 7)
            {
                he = 5;
            }
            //有文字
            NSString *content = [[[dict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
            cell.contentLabel.hidden = NO;
            cell.contentLabel.editable = NO;
            cell.contentLabel.textColor = CONTENTCOLOR;
            if ([content length] > 40)
            {
                cell.contentLabel.text  = [NSString stringWithFormat:@"%@...",[content substringToIndex:37]];
            }
            else
            {
                cell.contentLabel.text = content;
            }
            cell.contentLabel.frame = CGRectMake(10, 55, SCREEN_WIDTH-20, 45);
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
        }
        
        CGFloat imageViewHeight = ImageHeight;
        CGFloat imageViewWidth = ImageHeight;
        if ([[[dict objectForKey:@"detail"] objectForKey:@"img"] count] > 0)
        {
            //有图片
            
            NSArray *imgsArray = [[dict objectForKey:@"detail"] objectForKey:@"img"];
            NSInteger imageCount = [imgsArray count];
            if (imageCount == -1)
            {
                cell.imagesView.frame = CGRectMake((SCREEN_WIDTH-ImageHeight*ImageCountPerRow)/2,
                                                   cell.contentLabel.frame.size.height +
                                                   cell.contentLabel.frame.origin.y+7,
                                                   100, 100);
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(0, 0, 100, 100);
                imageView.userInteractionEnabled = YES;
                
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] imageWidth:100.0f andDefault:@"3100"];
                //                    [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] ];
                [cell.imagesView addSubview:imageView];
            }
            else
            {
                NSInteger row = 0;
                if (imageCount % ImageCountPerRow > 0)
                {
                    row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
                }
                else
                {
                    row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
                }
                cell.imagesView.frame = CGRectMake(12,
                                                   cell.contentLabel.frame.size.height +
                                                   cell.contentLabel.frame.origin.y+7,
                                                   SCREEN_WIDTH-44, (imageViewHeight+5) * row);
                
                for (int i=0; i<[imgsArray count]; ++i)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
                    imageView.userInteractionEnabled = YES;
                    imageView.tag = (indexPath.section-0-1)*SectionTag+indexPath.row*RowTag+i+333;
                    
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
                    // 内容模式
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"3100"];
                    [cell.imagesView addSubview:imageView];
                }
                
            }
        }
        else
        {
            cell.imagesView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
        }
        
        CGFloat cellHeight = cell.headerImageView.frame.size.height+cell.contentLabel.frame.size.height+cell.imagesView.frame.size.height+18;
        
        CGFloat he = 0;
        //            if (SYSVERSION >= 7.0)
        {
            he = 5;
        }
        
        CGFloat buttonHeight = 37;
        CGFloat iconH = 18;
        CGFloat iconTop = 9;
        
        cell.transmitButton.frame = CGRectMake(0, cellHeight+13, (SCREEN_WIDTH-10)/3, buttonHeight);
        [cell.transmitButton setTitle:@"   转发" forState:UIControlStateNormal];
        cell.transmitButton.iconImageView.image = [UIImage imageNamed:@"icon_forwarding"];
        cell.transmitButton.tag = indexPath.section*SectionTag+indexPath.row;
        [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.transmitButton.iconImageView.frame = CGRectMake(18, iconTop+1, iconH, iconH);
        cell.transmitButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
        {
            [cell.praiseButton setTitle:[NSString stringWithFormat:@"    %d",[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
        }
        else
        {
            [cell.praiseButton setTitle:@" 赞" forState:UIControlStateNormal];
        }
        if ([self havePraisedThisDiary:dict])
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"praised"];
            cell.praiseButton.iconImageView.frame = CGRectMake(27, iconTop, iconH, iconH);
        }
        else
        {
            cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"icon_heart"];
            cell.praiseButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
        }
        
        [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.praiseButton.tag = indexPath.section*SectionTag+indexPath.row;
        cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-10)/3, cellHeight+13, (SCREEN_WIDTH-10)/3, buttonHeight);
        cell.praiseButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
        {
            [cell.commentButton setTitle:[NSString stringWithFormat:@"   %d",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
        }
        else
        {
            [cell.commentButton setTitle:@"  评论" forState:UIControlStateNormal];
            cell.commentButton.iconImageView.frame = CGRectMake(18, iconTop, iconH, iconH);
        }
        cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-10)/3*2, cellHeight+13, (SCREEN_WIDTH-10)/3, buttonHeight);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
        cell.commentButton.tag = indexPath.section*SectionTag+indexPath.row;
        [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.geduan1.hidden = NO;
        cell.geduan2.hidden = NO;
        
        cell.geduan1.frame = CGRectMake(cell.transmitButton.frame.size.width+cell.transmitButton.frame.origin.x, cell.transmitButton.frame.origin.y+9.5, 1, 18);
        cell.geduan2.frame = CGRectMake(cell.praiseButton.frame.size.width+cell.praiseButton.frame.origin.x, cell.praiseButton.frame.origin.y+9.5, 1, 18);
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0 || [dict objectForKey:@"likes_num"] > 0)
        {
            NSArray *comArray = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
            if ([comArray count] > 0)
            {
                cell.commentsArray = comArray;
            }
            else
            {
                cell.commentsArray = nil;
            }
            NSArray *praiseArray = [[dict objectForKey:@"detail"] objectForKey:@"likes"];
            if ([praiseArray count] > 0)
            {
                cell.praiseArray = praiseArray;
            }
            else
            {
                cell.praiseArray = nil;
            }
            [cell.commentsTableView reloadData];
            cell.commentsTableView.frame = CGRectMake(0, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y, SCREEN_WIDTH, cell.commentsTableView.contentSize.height);
            cell.bgView.frame = CGRectMake(9.5, 0, SCREEN_WIDTH-19,
                                           cell.commentsTableView.frame.size.height+
                                           cell.commentsTableView.frame.origin.y);
        }
        else
        {
            cell.commentsArray = nil;
            cell.praiseArray = nil;
            [cell.commentsTableView reloadData];
            cell.bgView.frame = CGRectMake(9.5, 0, SCREEN_WIDTH-19,
                                           cell.praiseButton.frame.size.height+
                                           cell.praiseButton.frame.origin.y);
        }
        
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.clipsToBounds = YES;
        cell.bgView.backgroundColor = [UIColor whiteColor];
        
        
        cell.verticalLineView.frame = CGRectMake(34.75, 0, 1.5, cell.bgView.frame.size.height+10);
        
        return cell;
    }
    return nil;
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    if ([inputTabBar.inputTextView isFirstResponder])
    {
        [self backInput];
        [inputTabBar backKeyBoard];
    }
//    NSDictionary *groupDict = [tmpArray objectAtIndex:(tap.view.tag-333)/SectionTag];
//    NSArray *array = [groupDict objectForKey:@"diaries"];
//    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
//    NSArray *imgs = [dict objectForKey:@"img"];
    
    NSDictionary *groupDict = [tmpArray objectAtIndex:(tap.view.tag-333)/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
    NSArray *imgs = [[dict objectForKey:@"detail"] objectForKey:@"img"];
    int count = [imgs count];
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [NSString stringWithFormat:@"%@%@",IMAGEURL,imgs[i]];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url];
        photo.srcImageView = (UIImageView *)[self.bgView viewWithTag:tap.view.tag]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }

    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = ((tap.view.tag-333)%SectionTag)%RowTag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}


-(void)transmitDiary:(UIButton *)button
{
    if (fromClasses)
    {
        [Tools showTips:@"游客不能赞班级日志,赶快加入吧!" toView:self.bgView];
        return ;
    }
    
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    waitTransmitDict = [array objectAtIndex:button.tag%SectionTag];
    [self shareAPP:nil];
}

#pragma mark - shareAPP
-(void)shareAPP:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"QQ空间",@"腾讯微博",@"QQ好友",@"微信朋友圈",@"人人网", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"waittransdict %@",waitTransmitDict);
    switch (buttonIndex)
    {
        case 0:
            [self shareToSinaWeiboClickHandler:nil];
            break;
        case 1:
            [self shareToQQSpaceClickHandler:nil];
            break;
        case 2:
            [self shareToTencentWeiboClickHandler:nil];
            break;
        case 3:
            [self shareToQQFriendClickHandler:nil];
            break;
        case 4:
            [self shareToWeixinTimelineClickHandler:nil];
            break;
        case 5:
            [self shareToRenRenClickHandler:nil];
            break;
        default:
            break;
    }
}

/**
 *	@brief	分享到QQ空间
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQSpaceClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQSpace
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [self backInput];
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到新浪微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToSinaWeiboClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }

    //创建分享内容[ShareSDK imageWithUrl:imagePath]
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    [container setIPhoneContainerWithViewController:self];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [self backInput];
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到腾讯微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToTencentWeiboClickHandler:(UIButton *)sender
{
    
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeTencentWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [self backInput];
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@") , [error errorCode], [error errorDescription]);
                                 }
                             }];
}
/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQ
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [self backInput];
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享给微信朋友圈
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToWeixinTimelineClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到人人网
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToRenRenClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //    //创建弹出菜单容器
    //    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeRenren
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 [self backInput];
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     [self backInput];
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog( @"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}



-(void)praiseDiary:(UIButton *)button
{
    if (fromClasses)
    {
        [Tools showTips:@"游客不能赞班级日志,赶快加入吧!" toView:self.bgView];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [array objectAtIndex:button.tag%SectionTag];
        DDLOG(@"home diary %@",[[dict objectForKey:@"detail"] objectForKey:@"content"]);
        if ([Tools NetworkReachable])
        {
            __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                          @"token":[Tools client_token],
                                                                          @"p_id":[dict objectForKey:@"_id"],
                                                                          @"c_id":classID
                                                                          } API:LIKE_DIARY];
            [request setCompletionBlock:^{
                NSString *responseString = [request responseString];
                NSDictionary *responseDict = [Tools JSonFromString:responseString];
                DDLOG(@"commit diary responsedict %@",responseDict);
                if ([[responseDict objectForKey:@"code"] intValue]== 1)
                {
                    //                [Tools showTips:@"赞成功" toView:classTableView];
                    page = @"";
                    monthStr = @"";
                    [self getDongTaiList];
                    
                }
                else
                {
                    [Tools dealRequestError:responseDict fromViewController:nil];
                }
            }];
            
            [request setFailedBlock:^{
                NSError *error = [request error];
                DDLOG(@"error %@",error);
            }];
            [request startAsynchronous];
        }

    }
    
}

-(void)commentDiary:(UIButton *)button
{
    if (fromClasses)
    {
        [Tools showTips:@"游客不能赞班级日志,赶快加入吧!" toView:self.bgView];
        return ;
    }
    
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:button.tag%SectionTag];
    DDLOG(@"comment diary dict %@",dict);
    waitCommentDict = dict;
    [inputTabBar.inputTextView becomeFirstResponder];
    
//    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
//    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
//    dongtaiDetailViewController.addComDel = self;
//    [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [classZoneTableView addGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyBoardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
    }];
}

-(void)changeInputType:(NSString *)changeType
{
    if ([changeType isEqualToString:@"face"])
    {
        faceViewHeight = FaceViewHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-faceViewHeight, SCREEN_WIDTH, inputSize.height+10 + faceViewHeight);
    }
    else if([changeType isEqualToString:@"key"])
    {
        faceViewHeight = inputSize.height;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + faceViewHeight);
    }
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+faceViewHeight);
    }];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            NewDiariesViewController *newDiary = [[NewDiariesViewController alloc] init];
            newDiary.classID = classID;
            newDiary.classZoneDelegate = self;
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:newDiary animated:YES];
        }
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
        dongtaiDetailViewController.dongtaiId = [[array objectAtIndex:indexPath.row] objectForKey:@"_id"];
        dongtaiDetailViewController.addComDel = self;
        dongtaiDetailViewController.fromclass = YES;
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(BOOL)havePraisedThisDiary:(NSDictionary *)diaryDict
{
    NSArray *praiseArray = [[diaryDict objectForKey:@"detail"] objectForKey:@"likes"];
    for (int i = 0; i < [praiseArray count]; i++)
    {
        NSDictionary *dict = [praiseArray objectAtIndex:i];
        if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - addCommetnDel
-(void)addComment:(BOOL)add
{
    if (add)
    {
        page = @"";
        monthStr = @"";
        [self getDongTaiList];
    }
}

-(void)getMoreDongTai
{
    int tmppage = [page intValue];
    page = [NSString stringWithFormat:@"%d",++tmppage];
    [self getDongTaiList];
}

#pragma mark - aboutNetWork
-(void)getDongTaiList
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if ([page length] == 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID};
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID,
                         @"page":page,
                         @"month":monthStr};
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:GETDIARIESLIST];
        [request setCompletionBlock:^{
            [Tools hideProgress:classZoneTableView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diaries list responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([page length]== 0)
                {
                    [tmpArray removeAllObjects];
                    [DongTaiArray removeAllObjects];
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    if ([self.refreshDel respondsToSelector:@selector(reFreshClassZone:)])
                    {
                        [self.refreshDel reFreshClassZone:YES];
                    }
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count]>0)
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                    if ([array count] > 0)
                    {
                        classZoneTableView.hidden = NO;
                        [DongTaiArray addObjectsFromArray:array];
                    }
                    page = [NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue]];
                    monthStr = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                }
                else if ([page length] == 0 && [monthStr length]==0 )
                {
                    noneDongTaiLabel.hidden = NO;
                }
                else if([monthStr length] > 0 && [page integerValue]>0)
                {
                    [Tools showAlertView:@"没有更多动态了" delegateViewController:nil];
                }
                [self groupByTime:DongTaiArray];
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            [Tools hideProgress:classZoneTableView];
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [Tools showProgress:classZoneTableView];
        [request startAsynchronous];
    }
    else
    {
        _reloading = NO;
        [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    [tmpArray removeAllObjects];
    for (int i=index; i<[array count]; i++)
    {
        NSDictionary *dict = [array objectAtIndex:i];
        if ([dict isEqual:[NSNull null]])
        {
            continue ;
        }
        CGFloat sec = [[[dict objectForKey:@"created"] objectForKey:@"sec"] floatValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM月dd日"];
        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
        timeStr = [dateFormatter stringFromDate:datetimeDate];
        
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [groupDict setObject:timeStr forKey:@"date"];
        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
        [array2 addObject:dict];
        
        for (int j=i+1; j<[array count]; j++)
        {
            NSDictionary *dict2 = [array objectAtIndex:j];
            if ([dict2 isEqual:[NSNull null]])
            {
                continue;
            }
            CGFloat sec2 = [[[dict2 objectForKey:@"created"] objectForKey:@"sec"] floatValue];
            NSDate *datetimeDate2 = [NSDate dateWithTimeIntervalSince1970:sec2];
            NSString * timeStr2 = [dateFormatter stringFromDate:datetimeDate2];
            if ([timeStr2 isEqualToString:timeStr])
            {
                [array2 addObject:dict2];
            }
            else
            {
                index = j;
                break;
            }
        }
        if ([array2 count] > 0)
        {
            if (![self haveThisTime:timeStr])
            {
                [groupDict setObject:array2 forKey:@"diaries"];
                [tmpArray addObject:groupDict];
            }
        }
    }
    if ([tmpArray count] > 0)
    {
        noneDongTaiLabel.hidden = YES;
    }
    else
    {
        noneDongTaiLabel.hidden = NO;
    }
    [classZoneTableView reloadData];
    if (footerView)
    {
        [footerView removeFromSuperview];
        footerView = [[FooterView alloc] initWithScrollView:classZoneTableView];
        footerView.delegate = self;
    }
    else
    {
        footerView = [[FooterView alloc] initWithScrollView:classZoneTableView];
        footerView.delegate = self;
    }
}

-(BOOL)haveThisTime:(NSString *)timeStr
{
    for (int i=0; i<[tmpArray count]; i++)
    {
        NSDictionary *dict = [tmpArray objectAtIndex:i];
        if ([[dict objectForKey:@"date"] isEqualToString:timeStr])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isInAccessTime
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"])
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *fromatter = [[NSDateFormatter alloc] init];
        [fromatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeStr = [fromatter stringFromDate:date];
        DDLOG(@"timeStr==%@",timeStr);
        NSString *hourStr;
        NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
        NSRange containsA = [formatStringForHours rangeOfString:@"a"];
        BOOL hasAMPM = containsA.location != NSNotFound;
        
        if (hasAMPM)
        {
            //12
            [fromatter setDateFormat:@"KK"];
            hourStr = [fromatter stringFromDate:date];
            if ([timeStr rangeOfString:@"下午"].length > 0 || [timeStr rangeOfString:@"PM"].length > 0)
            {
                NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
                if ([timeLimit integerValue] ==2)
                {
                    if ([hourStr integerValue] < 7)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上7点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
                else if ([timeLimit integerValue] ==0)
                {
                    if ([hourStr integerValue] < 5)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上5点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
            }
            else
            {
                NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
                if ([timeLimit integerValue] ==2)
                {
                    if ([hourStr integerValue] < 7+12)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上7点以后"] delegateViewController:nil];
                        return NO;
                    }
                }
                else if ([timeLimit integerValue] ==0)
                {
                    if ([hourStr integerValue] < 5+12)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上5点以后"] delegateViewController:nil];
                        return NO;
                    }
                }

            }
        }
        else
        {
            //24
            [fromatter setDateFormat:@"HH"];
            hourStr = [fromatter stringFromDate:date];
            
            NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
            if ([timeLimit integerValue] ==2)
            {
                if ([hourStr integerValue] < 19)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上19点以后"] delegateViewController:nil];
                    return NO;
                }
            }
            else if ([timeLimit integerValue] ==0)
            {
                if ([hourStr integerValue] < 17)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"空间访问时间为晚上17点以后"] delegateViewController:nil];
                    return NO;
                }
            }
        }
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"visitor"]) && ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 0))
    {
        [Tools showAlertView:@"游客不可以查看班级空间！" delegateViewController:nil];
        return NO;
    }
    return YES;
}

-(void)getCacheData
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    DDLOG(@"classzone cache key %@",key);
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count] > 0)
            {
                [tmpArray removeAllObjects];
                classZoneTableView.hidden = NO;
                NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                [self groupByTime:array];
            }
            else
            {
                noneDongTaiLabel.hidden = NO;
            }
        }
    }
}
@end
