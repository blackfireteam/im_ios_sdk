//
//  BFMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>
#import "BFMessageCellData.h"



NS_ASSUME_NONNULL_BEGIN

@class BFMessageCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                              BFMessageCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////


@protocol BFMessageCellDelegate <NSObject>

/**
 *  长按消息回调
 *  您可以通过该回调实现：在被长按的消息上方弹出删除、撤回（消息发送者长按自己消息时）等二级操作。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onLongPressMessage:(BFMessageCell *)cell;

/**
 *  重发消息点击回调。
 *  在您点击重发图像（retryView）时执行的回调。
 *  您可以通过该回调实现：对相应的消息单元对应的消息进行重发。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onRetryMessage:(BFMessageCell *)cell;

/**
 *  点击消息回调
 *  通常情况下：点击声音消息 - 播放；点击文件消息 - 打开文件；点击图片消息 - 展示大图；点击视频消息 - 播放视频。
 *  通常情况仅对函数实现提供参考作用，您可以根据需求个性化实现该委托函数。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onSelectMessage:(BFMessageCell *)cell;

/**
 *  点击消息单元中消息头像的回调
 *  您可以通过该回调实现：响应用户点击，跳转到相应用户的详细信息界面。
 *
 *  @param cell 委托者，消息单元
 */
- (void)onSelectMessageAvatar:(BFMessageCell *)cell;
@end

@interface BFMessageCell : UITableViewCell

/**
 *  头像视图
 */
@property (nonatomic, strong) UIImageView *avatarView;

/**
 *  昵称标签
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 *  容器视图。
 *  包裹了 MesageCell 的各类视图，作为 MessageCell 的“底”，方便进行视图管理与布局。
 */
@property (nonatomic, strong) UIView *container;

/**
 *  活动指示器。
 *  在消息发送中提供转圈图标，表明消息正在发送。
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

/**
 *  重发视图。
 *  在发送失败后显示，点击该视图可以触发 onRetryMessage: 回调。
 */
@property (nonatomic, strong) UIImageView *retryView;

/**
 *  消息已读控件
 */
@property (nonatomic, strong) UILabel *readReceiptLabel;

/**
 *  协议委托
 *  负责实现 TMessageCellDelegate 协议中的功能。
 */
@property (nonatomic, weak) id<BFMessageCellDelegate> delegate;

@property(nonatomic,strong,readonly) BFMessageCellData *messageData;

/**
 *  单元填充函数
 *
 *  @param  data 填充数据源
 */
- (void)fillWithData:(BFMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
