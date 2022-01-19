//
//  MSSystemMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/20.
//
//存放系统消息所需要的信息与数据。
#import "MSMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MSSystemMessageType) {
    SYS_UNKNOWN = 0,  //未指定
    SYS_TIME,    //显示时间
    SYS_REVOKE,  //撤回提示
    SYS_OTHER
};

@interface MSSystemMessageCellData : MSMessageCellData


@property(nonatomic,assign) MSSystemMessageType type;

/**
 *  系统消息内容，例如“您撤回了一条消息。”
 */
@property (nonatomic, strong) NSString *content;

@property(nonatomic,strong) UIFont *contentFont;

@property(nonatomic,strong) UIColor *contentColor;


@end

NS_ASSUME_NONNULL_END
