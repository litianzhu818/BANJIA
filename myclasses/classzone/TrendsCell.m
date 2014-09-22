//
//  TrendsCell.m
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "TrendsCell.h"
#import "Header.h"
#import "UIButton+WebCache.h"
#import "CommentCell.h"
#import "NSString+Emojize.h"

#import "PersonDetailViewController.h"

#define CommentNameColor UIColorFromRGB(0x40c46d)

@implementation TrendsCell
@synthesize headerImageView,
nameLabel,
timeLabel,
locationLabel,
contentTextField,
contentLabel,
imagesView,
transmitButton,
praiseButton,
commentButton,
bgView,
nameTextField,
commentsTableView,
commentsArray,
praiseArray,
showAllComments,
nameButtonDel,
diaryDetailDict,
geduan1,
geduan2,
openPraise,
topImageView,
verticalLineView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        commentsArray = [[NSMutableArray alloc] initWithCapacity:0];
//        praiseArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        openPraise = YES;
        
        nameTextField = [[MyTextField alloc] init];
        nameTextField.hidden = YES;
        [self.contentView addSubview:nameTextField];
        
        bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = DongtaiBorderColor.CGColor;
        bgView.layer.borderWidth = 0.5;
        [self.contentView addSubview:bgView];
        
        topImageView = [[UIImageView alloc] init];
        topImageView.hidden = YES;
        [self.bgView addSubview:topImageView];
        
        headerImageView = [[UIImageView alloc] init];
        headerImageView.frame = CGRectMake(12, 12, 32, 32);
        headerImageView.hidden = YES;
        headerImageView.clipsToBounds = YES;
        headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        [bgView addSubview:headerImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(60, 5, 100, 30);
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.hidden = YES;
        [bgView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = COMMENTCOLOR;
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.hidden = YES;
        timeLabel.backgroundColor = [UIColor clearColor];
        [bgView addSubview:timeLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 35, SCREEN_WIDTH-170, 20)];
        locationLabel.textColor = LocationColor;
        locationLabel.hidden = YES;
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.font = [UIFont systemFontOfSize:12];
        [bgView addSubview:locationLabel];
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.hidden = YES;
        contentLabel.numberOfLines = 2;
        contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        contentLabel.textColor = CONTENTCOLOR;
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.backgroundColor = [UIColor clearColor];
        [bgView addSubview:contentLabel];
        
        contentTextField = [[UITextView alloc] init];
        contentTextField.scrollEnabled = NO;
        contentTextField.showsVerticalScrollIndicator = NO;
        contentTextField.editable = NO;
        contentTextField.hidden = YES;
        contentTextField.textColor = CONTENTCOLOR;
        contentTextField.font = [UIFont systemFontOfSize:15];
        contentTextField.backgroundColor = [UIColor clearColor];
        [bgView addSubview:contentTextField];
        
        imagesView = [[UIView alloc] init];
        imagesView.backgroundColor = [UIColor clearColor];
        imagesView.frame = CGRectMake(5, contentLabel.frame.size.height+contentLabel.frame.origin.y, SCREEN_WIDTH-10, 120);
        [bgView addSubview:imagesView];
        
        UIColor *titleColor = TITLE_COLOR;
        
        transmitButton = [MyButton buttonWithType:UIButtonTypeCustom];
        [transmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        transmitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        transmitButton.hidden = YES;
        [transmitButton setTitleColor:titleColor forState:UIControlStateNormal];
        transmitButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        transmitButton.layer.borderWidth = 0;
        [bgView addSubview:transmitButton];
        transmitButton.iconImageView.image = [UIImage imageNamed:@"icon_forwarding"];
        transmitButton.iconImageView.frame = CGRectMake(11, 9, 17, 17);
        
        
        praiseButton = [MyButton buttonWithType:UIButtonTypeCustom];
        praiseButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [praiseButton setTitleColor:titleColor forState:UIControlStateNormal];
        praiseButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        praiseButton.layer.borderWidth = 0;
        praiseButton.hidden = YES;
        [bgView addSubview:praiseButton];
        
        praiseButton.iconImageView.frame = CGRectMake(11, 10, 15, 15);
        
        commentButton = [MyButton buttonWithType:UIButtonTypeCustom];
        commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [commentButton setTitleColor:titleColor forState:UIControlStateNormal];
        commentButton.layer.borderColor = RGB(234, 234, 234, 1).CGColor;
        commentButton.layer.borderWidth = 0;
        commentButton.hidden = YES;
        [bgView addSubview:commentButton];
        commentButton.iconImageView.image= [UIImage imageNamed:@"icon_comment"];
        
        geduan1 = [[UIView alloc] init];
        geduan1.frame = CGRectMake(transmitButton.frame.size.width+
                                   transmitButton.frame.origin.x,
                                   transmitButton.frame.origin.y+ 5, 1, 25);
        geduan1.backgroundColor = UIColorFromRGB(0xe4e4e2);
        geduan1.hidden = YES;
        [self.bgView addSubview:geduan1];
        
        geduan2 = [[UIView alloc] init];
        geduan2.frame = CGRectMake(praiseButton.frame.size.width+
                                   praiseButton.frame.origin.x,
                                   praiseButton.frame.origin.y+ 5, 1, 25);
        geduan2.backgroundColor = UIColorFromRGB(0xe4e4e2);
        geduan2.hidden = YES;
        [self.bgView addSubview:geduan2];
        
        commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-10, 0) style:UITableViewStylePlain];
        commentsTableView.delegate = self;
        commentsTableView.dataSource = self;
        commentsTableView.scrollEnabled = NO;
        commentsTableView.layer.borderColor =DongtaiBorderColor.CGColor;
        commentsTableView.layer.borderWidth = 0.5;
        commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        commentsTableView.backgroundColor = CommentBgColor;
        if ([commentsTableView respondsToSelector:@selector(setSeparatorInset:)])
        {
            [commentsTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        [self.bgView addSubview:commentsTableView];
        
        verticalLineView = [[UIView alloc] init];
        verticalLineView.backgroundColor = UIColorFromRGB(0xe2e3e4);
        [self.contentView insertSubview:verticalLineView belowSubview:self.bgView];
        
        self.backgroundColor = UIColorFromRGB(0xf1f0ec);
        self.contentView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (commentsArray && praiseArray)
    {
        if(showAllComments)
        {
            return [commentsArray count]+1;
        }
        else
        {
            return ([commentsArray count]>6?7:[commentsArray count]) +1;
        }
        
    }
    else if(commentsArray && !praiseArray)
    {
        if (showAllComments)
        {
            return [commentsArray count];
        }
        else
        {
            return [commentsArray count] > 6 ? 7 : [commentsArray count];
        }
    }
    else if(!commentsArray && praiseArray)
    {
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = CommentFont;
    
    if (showAllComments)
    {
        if (commentsArray && praiseArray)
        {
            if (indexPath.row == 0)
            {
                int row = [praiseArray count]%ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
                return (PraiseH+5)*row+PraiseCellHeight+CommentSpace;
            }
            else
            {
                NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *content = [[commentDict objectForKey:@"content"] emojizedString];
                NSString *contentString = [NSString stringWithFormat:@"%@",content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:MaxCommentWidth-30 andFont:CommentFont];
                DDLOG(@"diary height in diary tools %@ +++ %@",contentString,NSStringFromCGSize(s));
                return s.height+CommentSpace*1+29;
            }
        }
        else if(commentsArray && !praiseArray)
        {
            NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
            NSString *name = [[commentDict objectForKey:@"by"] objectForKey:@"name"];
            NSString *content = [[commentDict objectForKey:@"content"] emojizedString];
            NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
            CGSize s = [Tools getSizeWithString:contentString andWidth:MaxCommentWidth-30 andFont:CommentFont];
            DDLOG(@"diary height in diary tools %@ +++ %@",contentString,NSStringFromCGSize(s));
            return s.height+CommentSpace*1+29;
        }
        if(praiseArray && !commentsArray)
        {
            if (openPraise)
            {
                int row = [praiseArray count]%ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
                return (PraiseH+5)*row+PraiseCellHeight+CommentSpace;
            }
        }
    }
    else
    {
        if (commentsArray && praiseArray)
        {
            if (indexPath.row == 0)
            {
                return PraiseCellHeight+CommentSpace;
            }
            else if(indexPath.row < 7)
            {
                NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [NSString stringWithFormat:@"%@ : ",[[commentDict objectForKey:@"by"] objectForKey:@"name"]];
                CGSize nameSize;
                if (SYSVERSION >= 7)
                {
                    nameSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CommentFont, NSFontAttributeName, nil]];
                }
                else
                {
                    nameSize = [Tools getSizeWithString:name andWidth:100 andFont:CommentFont];
                }
                NSString *content = [[commentDict objectForKey:@"content"] emojizedString];
                CGSize commentSize = [Tools getSizeWithString:content andWidth:MaxCommentWidth-nameSize.width andFont:font];
                return commentSize.height+CommentSpace*2;
            }
            else if(indexPath.row == 7)
            {
                return MinCommentHeight;
            }

        }
        else if(commentsArray && !praiseArray)
        {
            if (indexPath.row < 6)
            {
                NSDictionary *commentDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
                NSString *name = [NSString stringWithFormat:@"%@ : ",[[commentDict objectForKey:@"by"] objectForKey:@"name"]];
                CGSize nameSize;
                if (SYSVERSION >= 7)
                {
                    nameSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CommentFont, NSFontAttributeName, nil]];
                }
                else
                {
                    nameSize = [Tools getSizeWithString:name andWidth:100 andFont:CommentFont];
                }
                NSString *content = [[commentDict objectForKey:@"content"] emojizedString];
                CGSize commentSize = [Tools getSizeWithString:content andWidth:MaxCommentWidth-nameSize.width andFont:font];
                return commentSize.height+CommentSpace*2;
            }
            else if(indexPath.row == 6)
            {
                return MinCommentHeight;
            }
        }
        if(praiseArray && !commentsArray)
        {
            return PraiseCellHeight+CommentSpace;
        }

    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"homepraisecell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil)
    {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
//    cell.nameButton.hidden = YES;
//    CGFloat c_width = 15;
    CGFloat originalY = CommentSpace;
    cell.openPraiseButton.hidden = YES;
    [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
    [cell.nameButton setImage:nil forState:UIControlStateNormal];
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    
    cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    cell.lineImageView.hidden = NO;
    if (showAllComments)
    {
        if (praiseArray && commentsArray)
        {
            if (indexPath.row == 0)
            {
                cell.praiseView.hidden = NO;
                cell.nameButton.hidden = NO;
                [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
                cell.headerImageView.hidden = YES;
                
                cell.nameButton.frame = CGRectMake(12, CommentSpace, 18, 18);
//                [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
                cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
                cell.commentContentLabel.textColor = COMMENTCOLOR;
                cell.commentContentLabel.frame = CGRectMake(35, cell.nameButton.frame.origin.y, SCREEN_WIDTH-50, 18);
                cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.openPraiseButton.frame = CGRectMake(SCREEN_WIDTH-70, 3, 130, 130);
                cell.openPraiseButton.backgroundColor = [UIColor blackColor];
//                [cell.openPraiseButton addTarget:self action:@selector(openThisPraise) forControlEvents:UIControlEventTouchUpInside];
                cell.openPraiseButton = NO;
                
                for (UIView *v in cell.praiseView.subviews)
                {
                    [v removeFromSuperview];
                }
                
                for (int i=0; i<[praiseArray count]; ++i)
                {
                    NSDictionary *praiseDict = [praiseArray objectAtIndex:i];
                    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    headerButton.frame = CGRectMake((PraiseW+5)*(i%ColumnPerRow), (PraiseH+5)*(i/ColumnPerRow), PraiseW, PraiseH);
                    if ([[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] length] > 0)
                    {
                        [Tools fillButtonView:headerButton withImageFromURL:[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
                    }
                    else
                    {
                        [headerButton setImage:[UIImage imageNamed:HEADERICON] forState:UIControlStateNormal];
                    }
                    headerButton.layer.cornerRadius = 2;
                    headerButton.tag = 3333+i;
                    headerButton.clipsToBounds = YES;
                    headerButton.layer.cornerRadius = 3;
                    headerButton.clipsToBounds = YES;
                    [headerButton addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.praiseView addSubview:headerButton];
                }
                int row = [praiseArray count]%ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
                cell.praiseView.frame = CGRectMake(12, cell.commentContentLabel.frame.size.height+cell.commentContentLabel.frame.origin.y+CommentSpace, SCREEN_WIDTH-24, (PraiseH+9)*row);
                
                return cell;
            }
            else
            {
                cell.praiseView.hidden = YES;
                [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
                
                NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [NSString stringWithFormat:@"%@",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
                NSString *content = [[commitDict objectForKey:@"content"] emojizedString];
                CGSize s = [Tools getSizeWithString:content andWidth:MaxCommentWidth-30 andFont:CommentFont];
                cell.headerImageView.hidden = NO;
                cell.headerImageView.frame = CGRectMake(12, 10, PraiseW, PraiseW);
                cell.headerImageView.backgroundColor = [UIColor clearColor];
                [Tools fillImageView:cell.headerImageView withImageFromURL:[[commitDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
                cell.headerImageView.tag = [commentsArray count]-indexPath.row;
                cell.headerImageView.layer.cornerRadius = 2;
                cell.headerImageView.clipsToBounds = YES;
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)];
                cell.headerImageView.userInteractionEnabled = YES;
                [cell.headerImageView addGestureRecognizer:tap];
                
                cell.nameButton.hidden = NO;
                cell.nameButton.frame = CGRectMake(48, 7, 100, 20);
                cell.nameButton.backgroundColor = [UIColor clearColor];
                cell.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [cell.nameButton setTitle:name forState:UIControlStateNormal];
                
                cell.commentContentLabel.frame = CGRectMake(48, cell.nameButton.frame.size.height+cell.nameButton.frame.origin.y, MaxCommentWidth-30, s.height);
                cell.commentContentLabel.text = content;
                
                cell.timeLabel.frame = CGRectMake(150, 7, 150, 20);
                cell.timeLabel.text = [Tools showTime:[[commitDict objectForKey:@"created"] objectForKey:@"sec"]];
                cell.timeLabel.textColor = TIMECOLOR;
                cell.timeLabel.textAlignment = NSTextAlignmentRight;
                cell.timeLabel.font = [UIFont systemFontOfSize:12];
                
                return cell;
            }
        }
        else if(commentsArray && !praiseArray)
        {
            cell.nameButton.hidden = YES;
            cell.praiseView.hidden = YES;
            
            [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];

            
            NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
            NSString *name = [NSString stringWithFormat:@"%@",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
            NSString *content = [[commitDict objectForKey:@"content"] emojizedString];
            CGSize s = [Tools getSizeWithString:content andWidth:MaxCommentWidth-30 andFont:CommentFont];
            
            
            cell.headerImageView.hidden = NO;
            cell.headerImageView.frame = CGRectMake(12, 10, PraiseW, PraiseW);
            cell.headerImageView.backgroundColor = [UIColor clearColor];
            [Tools fillImageView:cell.headerImageView withImageFromURL:[[commitDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
            cell.headerImageView.tag = [commentsArray count]-indexPath.row-1;
            cell.headerImageView.layer.cornerRadius = 2;
            cell.headerImageView.clipsToBounds = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail:)];
            cell.headerImageView.userInteractionEnabled = YES;
            [cell.headerImageView addGestureRecognizer:tap];
            
            cell.nameButton.hidden = NO;
            cell.nameButton.frame = CGRectMake(48, 7, 100, 20);
            cell.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [cell.nameButton setTitle:name forState:UIControlStateNormal];
            cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"clearimage"]];
            
            cell.commentContentLabel.frame = CGRectMake(48, cell.nameButton.frame.size.height+cell.nameButton.frame.origin.y, MaxCommentWidth-30, s.height);
            cell.commentContentLabel.text = content;
            
            cell.timeLabel.frame = CGRectMake(150, 7, 150, 20);
            cell.timeLabel.text = [Tools showTime:[[commitDict objectForKey:@"created"] objectForKey:@"sec"]];
            cell.timeLabel.textColor = TIMECOLOR;
            cell.timeLabel.textAlignment = NSTextAlignmentRight;
            cell.timeLabel.font = [UIFont systemFontOfSize:12];

            return cell;
        }
        else if(!commentsArray && praiseArray)
        {
            cell.nameButton.hidden = NO;
            cell.praiseView.hidden = NO;
            [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
            
            cell.nameButton.frame = CGRectMake(12, CommentSpace, 18, 18);
//            [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
            cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
            cell.commentContentLabel.frame = CGRectMake(35, cell.nameButton.frame.origin.y, SCREEN_WIDTH-50, 18);
            cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
            cell.commentContentLabel.textColor = COMMENTCOLOR;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.openPraiseButton.frame = CGRectMake(SCREEN_WIDTH-70, 3, 30, 30);
            cell.openPraiseButton.backgroundColor = [UIColor greenColor];
            [cell.openPraiseButton addTarget:self action:@selector(openThisPraise) forControlEvents:UIControlEventTouchUpInside];
            cell.openPraiseButton = NO;
            
            for (UIView *v in cell.praiseView.subviews)
            {
                [v removeFromSuperview];
            }
            
            for (int i=0; i<[praiseArray count]; ++i)
            {
                NSDictionary *praiseDict = [praiseArray objectAtIndex:i];
                if (![praiseDict isEqual:[NSNull null]])
                {
                    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    headerButton.frame = CGRectMake((PraiseW+5)*(i%ColumnPerRow), (PraiseH+5)*(i/ColumnPerRow), PraiseW, PraiseH);
                    if ([[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] length] > 0)
                    {
                        [Tools fillButtonView:headerButton withImageFromURL:[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
                    }
                    else
                    {
                        [headerButton setImage:[UIImage imageNamed:HEADERICON] forState:UIControlStateNormal];
                    }
                    headerButton.layer.cornerRadius = 2;
                    headerButton.tag = 3333+i;
                    headerButton.clipsToBounds = YES;
                    [headerButton addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.praiseView addSubview:headerButton];
                }
            }
            int row = [praiseArray count] % ColumnPerRow == 0 ? ([praiseArray count]/ColumnPerRow):([praiseArray count]/ColumnPerRow+1);
            cell.praiseView.frame = CGRectMake(12, cell.commentContentLabel.frame.size.height+cell.commentContentLabel.frame.origin.y+CommentSpace, SCREEN_WIDTH-24, 40*row);

            return cell;
        }
    }
    else
    {
        if (praiseArray && commentsArray)
        {
            if (indexPath.row == 0)
            {
                cell.nameButton.hidden = NO;
                [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
                cell.praiseView.hidden = YES;
                
                cell.nameLable.hidden = YES;
                
                cell.nameButton.frame = CGRectMake(12, CommentSpace, 18, 18);
                [cell.nameButton setImage:[UIImage imageNamed:@"praised"] forState:UIControlStateNormal];
                
                cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
                cell.commentContentLabel.frame = CGRectMake(35, cell.nameButton.frame.origin.y, SCREEN_WIDTH-50, 18);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else if(indexPath.row < 7)
            {
                cell.nameButton.hidden = NO;
                [cell.nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
                
                NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
                NSString *name = [NSString stringWithFormat:@"%@ : ",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
                
                CGSize nameSize;
                if (SYSVERSION >= 7)
                {
                    nameSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CommentFont, NSFontAttributeName, nil]];
                }
                else
                {
                    nameSize = [Tools getSizeWithString:name andWidth:100 andFont:CommentFont];
                }
                cell.nameLable.hidden = NO;
                cell.nameLable.text = name;
                cell.nameLable.frame = CGRectMake(12, originalY, nameSize.width, nameSize.height);
                
                NSString *content = [[commitDict objectForKey:@"content"] emojizedString];
                
                CGSize commentSize = [Tools getSizeWithString:content andWidth:MaxCommentWidth-cell.nameLable.frame.size.width andFont:CommentFont];
                cell.commentContentLabel.text = content;
                cell.commentContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
                cell.commentContentLabel.numberOfLines = 1000;
                cell.commentContentLabel.frame = CGRectMake(cell.nameLable.frame.size.width+12, originalY, MaxCommentWidth-cell.nameLable.frame.size.width, commentSize.height);
                return cell;
            }
            else
            {
                cell.nameButton.hidden = NO;
                [cell.nameButton setImage:[UIImage imageNamed:@"home_more"] forState:UIControlStateNormal];
                cell.nameButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, 35);
                [cell.nameButton setTitle:@"查看更多" forState:UIControlStateNormal];
                [cell.nameButton addTarget:self action:@selector(showDiaryDetail) forControlEvents:UIControlEventTouchUpInside];
                [cell.nameButton setTitleColor:TIMECOLOR forState:UIControlStateNormal];
                return cell;
            }
        }
        else if(commentsArray && !praiseArray)
        {
            if (indexPath.row < 6)
            {
                cell.nameButton.hidden = YES;
                NSDictionary *commitDict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
                NSString *name = [NSString stringWithFormat:@"%@ : ",[[commitDict objectForKey:@"by"] objectForKey:@"name"]];
                
                CGSize nameSize;
                if (SYSVERSION >= 7)
                {
                    nameSize = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CommentFont, NSFontAttributeName, nil]];
                }
                else
                {
                    nameSize = [Tools getSizeWithString:name andWidth:100 andFont:CommentFont];
                }
                
                cell.nameLable.hidden = NO;
                cell.nameLable.text = name;
                cell.nameLable.frame = CGRectMake(12, originalY, nameSize.width, nameSize.height);
                
                NSString *content = [[commitDict objectForKey:@"content"] emojizedString];
                CGSize commentSize = [Tools getSizeWithString:content andWidth:MaxCommentWidth-nameSize.width andFont:CommentFont];
                cell.commentContentLabel.text = content;
                cell.commentContentLabel.frame = CGRectMake(cell.nameLable.frame.size.width+12, originalY, MaxCommentWidth-nameSize.width, commentSize.height);
                
                return cell;
            }
            else
            {
                [cell.nameButton setImage:[UIImage imageNamed:@"home_more"] forState:UIControlStateNormal];
                cell.nameButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, MinCommentHeight);
                [cell.nameButton setTitle:@"查看更多" forState:UIControlStateNormal];
                [cell.nameButton setTitleColor:TIMECOLOR forState:UIControlStateNormal];
                [cell.nameButton addTarget:self action:@selector(showDiaryDetail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
        }
        else if(!commentsArray && praiseArray)
        {
            cell.nameButton.hidden = NO;
            cell.nameButton.frame = CGRectMake(12, CommentSpace, 18, 18);
            cell.nameButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"praised"]];
            cell.commentContentLabel.frame = CGRectMake(35, cell.nameButton.frame.origin.y, SCREEN_WIDTH-50, 18);
            [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
            
            cell.nameLable.hidden = YES;
            cell.commentContentLabel.text = [NSString stringWithFormat:@"%d人觉得很赞",[praiseArray count]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *dict;
//    if ([praiseArray count] > 0)
//    {
//        dict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row];
//    }
//    else
//    {
//        dict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
//    }
    if (praiseArray && commentsArray)
    {
        if (indexPath.row == 0)
        {
            [self showDiaryDetail];
        }
        else
        {
            if ([self.nameButtonDel respondsToSelector:@selector(cellCommentDiary:)])
            {
                [self.nameButtonDel cellCommentDiary:diaryDetailDict];
            }
        }
    }
    else if (praiseArray && ! commentsArray)
    {
        [self showDiaryDetail];
    }
    else if(!praiseArray && commentsArray)
    {
        if ([self.nameButtonDel respondsToSelector:@selector(cellCommentDiary:)])
        {
            [self.nameButtonDel cellCommentDiary:diaryDetailDict];
        }
    }
}

-(void)nameClick:(UIButton *)button
{
    NSDictionary *dict = [commentsArray objectAtIndex:button.tag-3333];
    if ([self.nameButtonDel respondsToSelector:@selector(showPersonDetail:)])
    {
        [self.nameButtonDel showPersonDetail:dict];
    }
}
-(void)praiseClick:(UIButton *)button
{
    NSDictionary *dict = [praiseArray objectAtIndex:button.tag-3333];
    if ([self.nameButtonDel respondsToSelector:@selector(showPersonDetail:)])
    {
        [self.nameButtonDel showPersonDetail:dict];
    }
}
-(void)showDiaryDetail
{
    if ([self.nameButtonDel respondsToSelector:@selector(nameButtonClick:)])
    {
        [self.nameButtonDel nameButtonClick:diaryDetailDict];
    }
}

-(void)showDetail:(UITapGestureRecognizer *)tap
{
    NSDictionary *dict = [commentsArray  objectAtIndex:tap.view.tag];
    if ([self.nameButtonDel respondsToSelector:@selector(showPersonDetail:)])
    {
        [self.nameButtonDel showPersonDetail:dict];
    }
}

-(void)openThisPraise
{
    openPraise = !openPraise;
    [commentsTableView reloadData];
}
@end

//            cell.nameButton.frame = CGRectMake(SCREEN_WIDTH-80, 0, 60, 30);
//            cell.nameButton.backgroundColor = LIGHT_BLUE_COLOR;
//            [cell.nameButton addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];

//            for (int i=0; i<[praiseArray count]; ++i)
//            {
//                NSDictionary *praiseDict = [praiseArray objectAtIndex:i];
//                UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                headerButton.frame = CGRectMake(45*(i%4), 45*(i/4), 40, 40);
//                [Tools fillButtonView:headerButton withImageFromURL:[[praiseDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
//                headerButton.layer.cornerRadius = 20;
//                headerButton.tag = 3333+i;
//                headerButton.clipsToBounds = YES;
//                [headerButton addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.praiseView addSubview:headerButton];
//            }
//            int row = [praiseArray count]%4 == 0 ? ([praiseArray count]/4):([praiseArray count]/4+1);
//            cell.praiseView.frame = CGRectMake(25, 30, 180, 50*row);
