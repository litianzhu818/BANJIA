//
//  DongTaiDetailViewController.h
//  School
//
//  Created by TeekerZW on 14-2-28.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol DongTaiDetailAddCommentDelegate <NSObject>

-(void)addComment:(NSDictionary *)detailDict;

-(void)delDiary:(BOOL)del;

@end

@interface DongTaiDetailViewController : XDContentViewController
@property (nonatomic, strong) NSString *dongtaiId;
@property (nonatomic, assign) id<DongTaiDetailAddCommentDelegate> addComDel;
@property (nonatomic, assign) BOOL fromclass;
@property (nonatomic, assign) BOOL fromHome;
@end
