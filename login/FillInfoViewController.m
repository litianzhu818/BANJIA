//
//  FillInfoViewController.m
//  School
//
//  Created by TeekerZW on 14-1-23.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "FillInfoViewController.h"
#import "Header.h"
#import "MySwitchView.h"
#import "SideMenuViewController.h"
#import "MyClassesViewController.h"
#import "JDSideMenu.h"
#import "KKNavigationController.h"
#import "UIImageView+WebCache.h"
#import "HomeViewController.h"

#define NAMETFTAG   1000

@interface FillInfoViewController ()<UITextFieldDelegate,
UIScrollViewDelegate,
MySwitchDel,
UIActionSheetDelegate>
{
    UIScrollView *mainScrollView;
    UIImageView *headerImageView;
    MyTextField *nameTextfield;
    UITextField *emailTextField;
    UIButton *birthdayButton;
    
    UIDatePicker *datePicker;
    NSDateFormatter *formatter;
    BOOL showDatePicker;
    
    MySwitchView *sexSwitch;
    NSString *sex;
    
    UIImage *fullScreenImage;
    
    UIView *selectImageView;
    UIImagePickerController *imagePickerController;
}
@end

@implementation FillInfoViewController
@synthesize headerIcon,nickName,accountID,accountType,account,fromRoot;
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
    
    if (fromRoot)
    {
        self.titleLabel.text = @"完善信息";
        self.returnImageView.hidden = YES;
        self.backButton.hidden = YES;
    }
    else
    {
        self.titleLabel.text = @"注册成功";
    }
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.showsVerticalScrollIndicator = NO;
    [self.bgView addSubview:mainScrollView];
    
    CGFloat logoY = 272;
    if (FOURS)
    {
        logoY = 200;
    }
    
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    CGFloat imageH = logoImage.size.height-5;
    CGFloat imageW = logoImage.size.width-5;
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = logoImage;
    logoImageView.backgroundColor = [UIColor clearColor];
    logoImageView.alpha = 0.5;
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-imageW)/2,SCREEN_HEIGHT-logoY, imageW, imageH);
    [mainScrollView addSubview:logoImageView];
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, logoImageView.frame.origin.y+logoImageView.frame.size.height+30);

    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 46, 80, 30)];
    headerLabel.text = @"真人露相";
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.textColor = TITLE_COLOR;
    headerLabel.backgroundColor = [UIColor clearColor];
    [mainScrollView addSubview:headerLabel];
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headerLabel.frame.origin.x+headerLabel.frame.size.width+10, 39, 100, 100)];
    [headerImageView setImage:[UIImage imageNamed:HEADERBG]];
    headerImageView.backgroundColor = [UIColor clearColor];
    [mainScrollView addSubview:headerImageView];
    
    if ([headerIcon length] > 0)
    {
        [headerImageView setImageWithURL:[NSURL URLWithString:headerIcon] placeholderImage:[UIImage imageNamed:HEADERICON]];
    }
    
    UITapGestureRecognizer *selectHeaderImageTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectHeaderImage)];
    headerImageView.userInteractionEnabled = YES;
    [headerImageView addGestureRecognizer:selectHeaderImageTgr];
    
    nameTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, headerImageView.frame.origin.y+headerImageView.frame.size.height+27, SCREEN_WIDTH-29-24.5, 35)];
    nameTextfield.tag = NAMETFTAG;
    nameTextfield.delegate = self;
    nameTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameTextfield.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    if ([nickName length] > 0)
    {
        nameTextfield.text = nickName;
    }
    else
    {
        nameTextfield.placeholder = @"姓名";
    }
    nameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [mainScrollView addSubview:nameTextfield];
    
    sexSwitch = [[MySwitchView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-40, nameTextfield.frame.size.height+nameTextfield.frame.origin.y+10, 70, 30)];
    sexSwitch.selectView.frame = CGRectMake(sexSwitch.frame.size.width/2, 0, sexSwitch.frame.size.width/2, sexSwitch.frame.size.height);
    sexSwitch.mySwitchDel = self;
    sexSwitch.backgroundColor = RGB(65, 181, 186, 1);
    sexSwitch.leftView.layer.borderWidth = 0;
    sexSwitch.rightView.layer.borderWidth = 0;
    UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sexSwitch.frame.size.width/2, sexSwitch.frame.size.height)];
    maleLabel.text = @"男";
    maleLabel.textAlignment = NSTextAlignmentCenter;
    maleLabel.backgroundColor = [UIColor clearColor];
    maleLabel.textColor = [UIColor whiteColor];
    [sexSwitch.leftView addSubview:maleLabel];
    UILabel *fmaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sexSwitch.frame.size.width/2, sexSwitch.frame.size.height)];
    fmaleLabel.text = @"女";
    fmaleLabel.textColor = [UIColor whiteColor];
    fmaleLabel.textAlignment = NSTextAlignmentCenter;
    fmaleLabel.backgroundColor = [UIColor clearColor];
    [sexSwitch.rightView addSubview:fmaleLabel];
    [mainScrollView addSubview:sexSwitch];
    
    showDatePicker = NO;
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH - 20, 100)];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] ;
    datePicker.datePickerMode = UIDatePickerModeDate;
//    [mainScrollView addSubview:datePicker];
    
    NSDate *date = [datePicker date];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY年MM月dd日"];
    [birthdayButton setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(50, sexSwitch.frame.origin.y+sexSwitch.frame.size.height+45, SCREEN_WIDTH-100, 40);
    submitButton.backgroundColor = [UIColor clearColor];
    [submitButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)] forState:UIControlStateNormal];
    [submitButton setTitle:@"立即开始" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:submitButton];
    
    CGFloat oriY = 0;
    if (FOURS)
    {
        oriY = 10;
    }
    else
    {
        oriY = 20;
    }
    sex = @"1";
}

-(void)switchStateChanged:(MySwitchView *)mySwitchView
{
    if ([mySwitchView isOpen])
    {
        sex = @"0";
    }
    else
    {
        sex = @"1";
    }
    DDLOG(@"====%@",sex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [nameTextfield resignFirstResponder];
}

#pragma mark - 头像

-(void)selectHeaderImage
{
    [nameTextfield resignFirstResponder];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照", nil];
    [ac showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    imagePickerController.allowsEditing = YES;
    if (buttonIndex == 0)
    {
        //相册
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
    else if (buttonIndex == 1)
    {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else
        {
            [Tools showAlertView:@"相机不可用" delegateViewController:nil];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    fullScreenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (fullScreenImage.size.width>SCREEN_WIDTH*1.5 || fullScreenImage.size.height>SCREEN_HEIGHT*2)
    {
        CGFloat imageHeight = 0.0f;
        CGFloat imageWidth = 0.0f;
        if (fullScreenImage.size.width>SCREEN_WIDTH*1.5)
        {
            imageWidth = SCREEN_WIDTH*1.5;
            imageHeight = imageWidth*fullScreenImage.size.height/fullScreenImage.size.width;
        }
        else
        {
            imageHeight = SCREEN_HEIGHT*1.5;
            imageWidth = imageHeight*fullScreenImage.size.width/fullScreenImage.size.height;
        }
        fullScreenImage = [Tools thumbnailWithImageWithoutScale:fullScreenImage size:CGSizeMake(imageWidth, imageHeight)];
    }
    
    [headerImageView setImage:fullScreenImage];
}

-(void)uploadImage:(UIImage *)image
{
    if ([Tools NetworkReachable])
    {
        UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(headerImageView.frame.size.width/2-20, headerImageView.frame.size.height/2-20, 40, 40)];
        indi .activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [headerImageView addSubview:indi];
        
        __weak ASIHTTPRequest *request = [Tools upLoadImages:[NSArray arrayWithObject:image] withSubURL:SETUSERIMAGE andParaDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token],@"img_type":@"img_icon"}];
        
        [request setCompletionBlock:^{
            
            [indi stopAnimating];
            [indi removeFromSuperview];
            
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"upload image responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *img_icon = [[responseDict objectForKey:@"data"] objectForKey:@"files"];
                [[NSUserDefaults standardUserDefaults] setObject:img_icon forKey:HEADERIMAGE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [indi startAnimating];
        [request startAsynchronous];
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)submitClick
{
    
    if ([nameTextfield.text length] == 0)
    {
        [Tools showAlertView:@"请输入您的姓名" delegateViewController:nil];
        return;
    }
    if ([sexSwitch isOpen])
    {
        //nv
        sex = @"0";
    }
    else
    {
        sex = @"1";
    }
    
    NSDictionary *paraDict;
    NSString *url;
    if ([accountID length] > 0)
    {
        NSString *userStr = @"simu";
        if ([[APService registrionID] length] > 0)
        {
            userStr = [APService registrionID];
        }

        paraDict = @{@"a_id":accountID,
                      @"a_type":accountType,
                      @"c_ver":[Tools client_ver],
                      @"d_name":[Tools device_name],
                      @"d_imei":[Tools device_uid],
                      @"c_os":[Tools device_os],
                      @"d_type":@"iOS",
                      @"p_cid":@"123",
                      @"p_uid":userStr,
                      @"r_name":nameTextfield.text,
                      @"sex":sex,
                      @"reg":@"1"
                    };
        url = LOGINBYAUTHOR;
    }
    else
    {
        paraDict = @{@"sex":sex,
                     @"r_name":nameTextfield.text,
                     @"u_id":[Tools user_id],
                     @"token":[Tools client_token]
                     };
        url = MB_SUBINFO;
    }
    
    if ([Tools NetworkReachable])
    {
        if (fullScreenImage)
        {
            [self uploadImage:fullScreenImage];
        }
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:url];
        
        [request setCompletionBlock:^{
            
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:nameTextfield.text forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] setObject:sex forKey:USERSEX];
                if ([accountID length]>0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"token"] forKey:CLIENT_TOKEN];
                    [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"u_id"] forKey:USERID];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                HomeViewController *homeViewController = [[HomeViewController alloc] init];
                KKNavigationController *homeNav = [[KKNavigationController alloc] initWithRootViewController:homeViewController];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:homeNav menuController:sideMenuViewController];
                [self.navigationController presentViewController:sideMenu animated:YES completion:^{
                    
                }];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }

}

-(void)showPickerView
{
    if (showDatePicker)
    {
        [UIView animateWithDuration:.3 animations:^{
            datePicker.frame = CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH - 20, 100);
        }];
        NSDate *date = [datePicker date];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年MM月dd日"];
        [birthdayButton setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
    }
    else
    {
        [UIView animateWithDuration:.3 animations:^{
            datePicker.frame = CGRectMake(10, birthdayButton.frame.size.height+birthdayButton.frame.origin.y+30, SCREEN_WIDTH - 20, 100);
        }];

    }
    showDatePicker = !showDatePicker;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *v in self.bgView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]])
        {
            if (![v isExclusiveTouch])
            {
                [v resignFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    self.bgView.center = CENTER_POINT;
                }completion:^(BOOL finished) {
                    
                }];
                
            }
        }
    }
    
}

#pragma mark - textfield
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        if (textField.tag == NAMETFTAG)
        {
            if (FOURS)
            {
                self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-50);
            }
            else
            {
                self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-20);
            }
        }
        else if(textField.tag == 1001)
        {
            self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-40);
        }
    }completion:^(BOOL finished) {
        
    }];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - textfield
- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
//    //获取键盘的高度
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
////    int height = keyboardRect.size.height;
//    
//    [UIView animateWithDuration:0.25 animations:^{
//        //        if (iPhone5)
//        //        {
//        //            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+100);
//        //        }
//        //        else
//        //        {
//        //            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+50);
//        //        }
//        
//    }completion:^(BOOL finished) {
//    }];
}
@end
