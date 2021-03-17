//
//  BFMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MSIMElem.h"
#import "BFMessageCellLayout.h"

/**
 *  消息方向枚举
 *  消息方向影响气泡图标、气泡位置等 UI 风格。
 */
typedef NS_ENUM(NSUInteger, TMsgDirection) {
    MsgDirectionIncoming, //消息接收
    MsgDirectionOutgoing, //消息发送
};
NS_ASSUME_NONNULL_BEGIN

@interface BFMessageCellData : NSObject

@property(nonatomic,strong) UIImage *avatarImage;

@property(nonatomic,strong) NSURL *avatarURL;

@property(nonatomic,copy) NSString *nickName;

@property(nonatomic,assign) TMsgDirection direction;

@property(nonatomic,assign) BOOL showName;

@property(nonatomic,strong) MSIMElem *elem;

@property(nonatomic,strong) BFMessageCellLayout *cellLayout;

@property(nonatomic,copy,readonly) NSString *reuseId;

/**
 *  内容大小
 *  返回一个气泡内容的视图大小。
 */
- (CGSize)contentSize;

/**
 *  根据消息方向（收/发）初始化消息单元
 *  除了基本消息的初始化外，还包括根据方向设置方向变量、昵称字体等。
 *  同时为子类提供可继承的行为。
 *
 *  @param direction 消息方向。MsgDirectionIncoming：消息接收；MsgDirectionOutgoing：消息发送。
 */
- (instancetype)initWithDirection:(TMsgDirection)direction;

- (CGFloat)heightOfWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
