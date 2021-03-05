//
//  BFMessageCellLayout.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface BFMessageCellLayout : NSObject

/**
 * 消息边距
 */
@property(nonatomic,assign) UIEdgeInsets messageInsets;

/**
 * 气泡内部内容边距
 */
@property(nonatomic,assign) UIEdgeInsets bubbleInsets;

/**
 * 头像边距
 */
@property(nonatomic,assign) UIEdgeInsets avatarInsets;

/**
 * 头像大小
 */
@property(nonatomic,assign) CGSize avatarSize;

/////////////////////////////////////////////////////////////////////////////////
//                      文本消息布局
/////////////////////////////////////////////////////////////////////////////////

/**
 *  获取文本消息（接收）布局
 */
+ (BFMessageCellLayout *)incommingTextMessageLayout;

/**
 *  获取文本消息（发送）布局
 */
+ (BFMessageCellLayout *)outgoingTextMessageLayout;


/////////////////////////////////////////////////////////////////////////////////
//                      语音消息布局
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取语音消息（接收）布局
 */
+ (BFMessageCellLayout *)incommingVoiceMessageLayout;

/**
 *  获取语音消息（发送）布局
 */
+ (BFMessageCellLayout *)outgoingVoiceMessageLayout;


/////////////////////////////////////////////////////////////////////////////////
//                      系统消息布局
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取系统消息布局
 */
+ (BFMessageCellLayout *)systemMessageLayout;

/////////////////////////////////////////////////////////////////////////////////
//                      其他消息布局
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取接收消息布局
 */
+ (BFMessageCellLayout *)incommingMessageLayout;

/**
 *  获取发送消息布局
 */
+ (BFMessageCellLayout *)outgoingMessageLayout;

@end

NS_ASSUME_NONNULL_END
