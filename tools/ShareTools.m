//
//  ShareTools.m
//  BANJIA
//
//  Created by TeekerZW on 14/10/23.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ShareTools.h"

@implementation ShareTools

- (void)shareTo:(ShareType)shareType
andShareContent:(NSString *)shareContent
      andImage:(id<ISSCAttachment>)attachment
  andMediaType:(SSPublishContentMediaType)mediaType
   description:(NSString *)description
        andUrl:(NSString *)url
{
    NSString *title = @"班家";
    if (shareType == ShareTypeWeixiTimeline)
    {
        title = [NSString stringWithFormat:@"%@",shareContent];
    }
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@-%@",shareContent,ShareUrl]
                                       defaultContent:shareContent
                                                image:attachment
                                                title:title
                                                  url:ShareUrl
                                          description:description
                                            mediaType:mediaType];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
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
    [ShareSDK showShareViewWithType:shareType
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
                                 DDLOG(@"%@",statusInfo);
                                 if (state == SSResponseStateSuccess)
                                 {
                                     DDLOG(@"share success!");
                                     
                                     if ([self.shareContentDel respondsToSelector:@selector(shareSuccess)])
                                     {
                                         [self.shareContentDel shareSuccess];
                                     }
                                 }
                                 else if (state == SSResponseStateFail)
                                 {
                                     DDLOG(@"%@",[error errorDescription]);
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                     
                                 }
                             }];
    
}


@end
