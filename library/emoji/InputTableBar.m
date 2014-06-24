//
//  InputTableBar.m
//  FaceDemo
//
//  Created by TeekerZW on 3/26/14.
//
//

#import "InputTableBar.h"
#import "Header.h"
#define FaceViewTag  1000

@implementation InputTableBar
@synthesize inputTextView,inputBgView,face,returnFunDel,sendString;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        sendString = [[NSMutableString alloc] initWithCapacity:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        face = YES;
        
        fileNameArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        inputTextViewSize = CGSizeMake(250, 30);
        
        inputBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 40)];
        inputBgView.backgroundColor = RGB(91, 91, 91, 1);
        inputBgView.layer.anchorPoint = CGPointMake(0.5, 1);
        [self addSubview:inputBgView];
        
        inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, 250, 30)];
        inputTextView .backgroundColor = [UIColor whiteColor];
        inputTextView.returnKeyType = UIReturnKeySend;
        inputTextView.autoresizingMask = YES;
        inputTextView.delegate = self;
        inputTextView.layer.cornerRadius = 5;
        inputTextView.clipsToBounds = YES;
        inputTextView.showsVerticalScrollIndicator = NO;
        inputTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        inputTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        inputTextView.font = [UIFont systemFontOfSize:16];
        [inputBgView addSubview:inputTextView];
        
        inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
        inputButton.frame = CGRectMake(SCREEN_WIDTH-50, 5, 40, 30);
        inputButton.backgroundColor = [UIColor clearColor];
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        [inputButton addTarget:self action:@selector(changeInputType) forControlEvents:UIControlEventTouchUpInside];
        [inputBgView addSubview:inputButton];
        
        faceView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, FaceViewHeight+40, SCREEN_WIDTH, 0)];
        faceView.backgroundColor = [UIColor lightGrayColor];
        faceView.pagingEnabled = YES;
        faceView.tag = FaceViewTag;
        faceView.bounces = NO;
        faceView.delegate = self;
        [self addSubview:faceView];
        
        faceDict = [NSString emojiAliases];
        
        NSInteger row = 4;
        NSInteger colum = 7;
        NSInteger i=0;
        NSInteger count=0;
        CGFloat faceWidth = SCREEN_WIDTH/colum;
        CGFloat faceHeight = faceWidth;
        
        NSString *path = [self getParentPath:[[NSBundle mainBundle] pathForResource:@"emoji_-1" ofType:@"png"]];
        
        NSArray *fileArray = [self getContentsOfDirectoryAtPath:path];
        for(NSString *name in fileArray)
        {
            if ([name rangeOfString:@"emoji_"].length > 0)
            {
                [fileNameArray addObject:name];
            }
        }
        faceArray = @[@"smile",
                      @"wink",
                      @"hushed",
                      @"kissing_smiling_eyes",
                      @"kissing",
                      @"kissing_heart",
                      @"laughing",
                      @"tired_face",
                      @"unamused",
                      @"neutral_face",
                      @"open_mouth",
                      @"sleeping",
                      @"stuck_out_tongue",
                      @"stuck_out_tongue_closed_eyes",
                      @"stuck_out_tongue_winking_eye",
                      @"yum",
                      @"astonished",
                      @"flushed",
                      @"frowning",
                      @"grimacing",
                      @"grinning",
                      @"heart_eyes",
                      @"sob",
                      @"rage",
                      @"joy",
                      @"kissing_closed_eyes",
                      @"kissing_heart",
                      @"mask",
                      @"no_mouth",
                      @"pensive",
                      @"sweat",
                      @"sunglasses",
                      @"innocent",
                      @"sleepy",
                      @"disappointed_relieved",
                      @"sweat_smile",
                      @"cold_sweat",
                      @"fearful",
                      @"scream",
                      @"eyes",
                      @"poop",
                      @"pray",
                      @"tongue",
                      @"ear",
                      @"thumbsup",
                      @"thumbsdown",
                      @"clap",
                      @"raised_hand",
                      @"wave",
                      @"open_hands",
                      @"raised_hands",
                      @"ok_hand",
                      @"point_up",
                      @"v",
                      @"point_up_2",
                      @"point_left",
                      @"point_down",
                      @"point_right",
                      @"punch",
                      @"muscle",
                      @"kiss",
                      @"heart",
                      @"broken_heart",
                      @"heartpulse",
                      @"heartbeat",
                      @"cupid",
                      @"smile_cat",
                      @"smiley_cat",
                      @"crying_cat_face",
                      @"smirk_cat",
                      @"pouting_cat",
                      @"heart_eyes_cat",
                      @"mouse",
                      @"tiger",
                      @"rabbit",
                      @"snake",
                      @"sheep",
                      @"dog",
                      @"pig",
                      @"bird",
                      @"frog",
                      @"hear_no_evil",
                      @"speak_no_evil",
                      @"see_no_evil",
                      @"monkey",
                      @"bear",
                      @"wolf",
                      @"older_woman",
                      @"person_with_blond_hair",
                      @"princess",
                      @"baby",
                      @"bow",
                      @"boy",
                      @"man",
                      @"older_man",
                      @"girl",
                      @"woman",
                      @"bride_with_veil",
                      @"older_woman",
                      @"construction_worker",
                      @"cop",
                      @"guardsman",
                      @"man_with_gua_pi_mao",
                      @"no_good",
                      @"person_frowning",
                      @"couple_with_heart",
                      @"couplekiss",
                      @"family",
                      @"cloud",
                      @"zap",
                      @"foggy",
                      @"snowflake",
                      @"exclamation",
                      @"grey_exclamation",
                      @"grey_question"];
        
        DDLOG(@"dddd ---\U00002653");
        for (;i<[faceArray count];)
        {
            NSString *faceName = [NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",[faceArray objectAtIndex:i]]];
            
            UITapGestureRecognizer *faceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceClick:)];
            UILabel *faceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+SCREEN_WIDTH*(count/(row*colum)) +faceWidth*((count%(row*colum))%colum),5+ faceHeight*((i%(row*colum))/colum), faceWidth-5, faceHeight-5)];
            faceLabel.tag = i;
            faceLabel.text = faceName;
            faceLabel.textAlignment = NSTextAlignmentCenter;
            faceLabel.font = [UIFont systemFontOfSize:30];
            faceLabel.backgroundColor = [UIColor clearColor];
            faceLabel.userInteractionEnabled = YES;
            [faceLabel addGestureRecognizer:faceTap];
            [faceView addSubview:faceLabel];
            count++;
            i++;
        }
        
        int page = count%(row*colum)>0?(count/(row*colum)+1):(count/(row*colum));
        
        faceView.contentSize = CGSizeMake(SCREEN_WIDTH*page, FaceViewHeight);
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height+faceView.frame.origin.y-50, 140, 0)];
        pageControl.backgroundColor = [UIColor clearColor];
        pageControl.numberOfPages = page;
        pageControl.hidden = YES;
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        [self addSubview:pageControl];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == FaceViewTag)
    {
        pageControl.currentPage = scrollView.contentOffset.x/SCREEN_WIDTH;
    }
}

- (NSString *)getParentPath:(NSString *)aPath
{
    return [aPath stringByDeletingLastPathComponent];
}

- (NSArray *)getContentsOfDirectoryAtPath:(NSString *)aDirString

{
    NSFileManager *tempFileManager = [NSFileManager defaultManager];
    return [tempFileManager contentsOfDirectoryAtPath:aDirString
                                                error:nil];
}

-(void)changeInputType
{
    if (face)
    {
        //切换到表情
        [inputTextView resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0, SCREEN_HEIGHT-FaceViewHeight-inputTextViewSize.height-10, SCREEN_WIDTH, FaceViewHeight+inputTextViewSize.height);
            faceView.frame = CGRectMake(0, inputTextViewSize.height+10, SCREEN_WIDTH, FaceViewHeight);
            pageControl.frame = CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height+faceView.frame.origin.y-50, 140, 30);
            pageControl.hidden = NO;
            [inputButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"face"];
            }
        }];
    }
    else
    {
        //切换到键盘
        [inputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(0,SCREEN_HEIGHT - keyBoardHeight-inputTextViewSize.height-10, SCREEN_WIDTH, inputTextViewSize.height);
            faceView.frame = CGRectMake(0, FaceViewHeight+inputTextViewSize.height+10, SCREEN_WIDTH, 0);
            pageControl.frame = CGRectMake(SCREEN_WIDTH/2-70, faceView.frame.size.height+faceView.frame.origin.y-50, 140, 0);
            pageControl.hidden = YES;
            [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
            if ([self.returnFunDel respondsToSelector:@selector(changeInputType:)])
            {
                [self.returnFunDel changeInputType:@"keyboard"];
            }
        }];
    }
    face = !face;
}

-(void)faceClick:(UITapGestureRecognizer *)tgr
{
    
    if ((tgr.view.tag+1)%28 != 0)
    {
        NSString *text = [inputTextView text];
        NSString *imageFileName = [[faceArray objectAtIndex:tgr.view.tag] emojizedString];
        [sendString insertString:[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]] atIndex:[sendString length]];
        NSString *text2 = @"";
        text2 = [text stringByAppendingString:[NSString emojizedStringWithString:[NSString stringWithFormat:@":%@:",imageFileName]]];
        inputTextView.text = text2;
    }
}

//-(void)layOutWithKeyBoardHeight:(CGFloat)keyBoardHeight
//{
//    inputBgView.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, keyBoardHeight+40);
//    faceView.frame = CGRectMake(0, 40, SCREEN_WIDTH, keyBoardHeight);
//}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT-keyBoardHeight-inputTextViewSize.height-10, SCREEN_WIDTH, FaceViewHeight+inputTextViewSize.height+10);
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        if ([self.returnFunDel respondsToSelector:@selector(showKeyBoard:)])
        {
            [self.returnFunDel showKeyBoard:keyBoardHeight];
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    }completion:^(BOOL finished) {
        
    }];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        inputTextViewSize = CGSizeMake(250, 30);
        [self inputChange];
        if ([self.returnFunDel respondsToSelector:@selector(myReturnFunction)])
        {
            [self.returnFunDel myReturnFunction];
        }
        [textView setText:nil];
        [sendString  setString:@""];
        return NO;
    }
    [sendString insertString:text atIndex:[sendString length]];
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize size = textView.contentSize;
    inputTextViewSize = size;
    [self inputChange];
    
    
    if ([textView.text length] > 200)
    {
        [Tools showAlertView:@"字数不能超过200" delegateViewController:nil];
        return ;
    }
    
    if ([self.returnFunDel respondsToSelector:@selector(changeInputViewSize:)])
    {
        [self.returnFunDel changeInputViewSize:size];
    }
}

-(void)inputChange
{
    [UIView animateWithDuration:0.2 animations:^{
        inputButton.frame = CGRectMake(SCREEN_WIDTH-50, 5+inputTextViewSize.height-30, 40, 30);
        inputBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, inputTextViewSize.height+10);
        inputTextView.frame = CGRectMake(10, 5, 250 , inputTextViewSize.height);
    }];
}

-(void)backKeyBoard
{
    [UIView animateWithDuration:0.2 animations:^{
        [inputTextView resignFirstResponder];
        [inputButton setImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    }];
}

-(NSString *)findEmoStrWithStr:(NSString *)text
{
    NSDictionary *emojiDict = [NSString emojiAliases];
    for(NSString *key in emojiDict)
    {
        if ([text isEqualToString:[emojiDict objectForKey:key]])
        {
            return key;
        }
    }
    return @"";
}

-(NSMutableString *)analyString:(NSString *)inputString
{
    NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:inputString];
    NSDictionary *emojiDict = [NSString emojiAliases];
    for(NSString *key in emojiDict)
    {
        NSString *emoEncodeStr = [emojiDict objectForKey:key];
        if ([tmpStr rangeOfString:emoEncodeStr].length > 0)
        {
            [tmpStr replaceCharactersInRange:[tmpStr rangeOfString:emoEncodeStr] withString:key];
        }
    }
    return tmpStr;
}

@end
