//
//  MSUIConversationCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/5/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSIMConversation;
@interface MSUIConversationCellData : NSObject

@property(nonatomic,strong) MSIMConversation *conv;

@property (nonatomic, strong,readonly) UIImage *avatarImage;

@property (nonatomic, strong,readonly) NSString *title;

/**
 *  会话消息概览（下标题）
 *  概览负责显示对应会话最新一条消息的内容/类型。
 *  当最新的消息为文本消息/系统消息时，概览的内容为消息的文本内容。
 *  当最新的消息为多媒体消息时，概览的内容为对应的多媒体形式，如：“动画表情” / “[文件]” / “[语音]” / “[图片]” / “[视频]” 等。
 *  若当前会话有草稿时，概览内容为：“[草稿]XXXXX”，XXXXX为草稿内容。
 */
@property (nonatomic, strong,readonly) NSAttributedString *subTitle;

/**
 *  最新消息时间
 *  记录会话中最新消息的接收/发送时间。
 */
@property (nonatomic, strong,readonly,nullable) NSDate *time;

@end

NS_ASSUME_NONNULL_END
