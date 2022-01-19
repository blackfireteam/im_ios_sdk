//
//  MSUIConversationCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/5/28.
//

#import <UIKit/UIKit.h>
#import "MSUnreadView.h"
#import "MSUIConversationCellData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】消息列表会话单元（MSUIConversationCell）
 *
 * 【功能说明】在消息列表界面中，显示单个会话的预览信息。
 *  会话单元所展示的会话信息包括：
 *  1、头像信息（用户头像/群头像）
 *  2、会话标题（用户昵称/群名称）
 *  3、会话消息概览（展示最新的一条的消息内容）
 *  4、未读消息数（若有未读消息的话）
 *  5、会话时间（最新消息的收到/发出时间）
 */

@interface MSUIConversationCell : UITableViewCell

/** 用户头像*/
@property (nonatomic, strong) UIImageView *headImageView;

/** 用户昵称*/
@property(nonatomic,strong) UILabel *titleLabel;

/**
 *  会话消息概览（下标题）
 *  概览负责显示对应会话最新一条消息的内容/类型。
 *  当最新的消息为文本消息/系统消息时，概览的内容为消息的文本内容。
 *  当最新的消息为多媒体消息时，概览的内容为对应的多媒体形式，如：“动画表情” / “[文件]” / “[语音]” / “[图片]” / “[视频]” 等。
 *  若当前会话有草稿时，概览内容为：“[草稿]XXXXX”，XXXXX为草稿内容。
 */
@property(nonatomic,strong) UILabel *subTitleLabel;

/**
 *  时间标签
 *  负责在会话单元中显示最新消息的接收/发送时间。
 *  对于当天的消息，以 “HH：MM”的格式显示时间。
 *  对于非当天的消息，则显示消息收/发当天为星期几。
 */
@property(nonatomic,strong) UILabel *timeLabel;

/** 性别图标*/
@property(nonatomic,strong) UIImageView *genderIcon;

/**
 *  未读视图
 *  如果当前会话有消息未读的话，则在会话单元右侧显示红底白字的原型图标来展示未读数量。
 */
@property(nonatomic,strong) MSUnreadView *unReadView;

@property(nonatomic,strong) MSUIConversationCellData *convData;

/**
 *  填充数据
 */
- (void)configWithData:(MSUIConversationCellData *)convData;


@end

NS_ASSUME_NONNULL_END
