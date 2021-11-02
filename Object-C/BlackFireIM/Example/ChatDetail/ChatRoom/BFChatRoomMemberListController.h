//
//  BFChatRoomMemberListController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import "BFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MSChatRoomInfo;
@interface BFChatRoomMemberListController : BFBaseViewController

@property(nonatomic,strong) MSChatRoomInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END
