//
//  BFEditTodInfoController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/8.
//

#import "BFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MSGroupInfo;
@interface BFEditTodInfoController : BFBaseViewController


@property(nonatomic,strong) MSGroupInfo *roomInfo;

@property(nonatomic,copy) void(^editComplete)(void);
@end

NS_ASSUME_NONNULL_END
