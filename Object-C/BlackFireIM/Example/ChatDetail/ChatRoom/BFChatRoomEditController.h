//
//  BFChatRoomEditController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/7.
//

#import "BFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MSGroupInfo;
@interface BFChatRoomEditController : BFBaseViewController

@property(nonatomic,strong) MSGroupInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END
