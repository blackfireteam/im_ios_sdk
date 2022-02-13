//
//  MSGroupMessageController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSChatRoomMessageController;
@class MSMessageCell;
@class MSMessageCellData;
@class MSIMMessage;
@class MSGroupInfo;
@protocol MSChatRoomMessageControllerDelegate <NSObject>


/**
 *  每条新消息在进入气泡展示区之前，都会通知给您
 */
- (MSMessageCellData *)messageController:(MSChatRoomMessageController *)controller prepareForMessage:(MSIMMessage *)message;

/**
 *  显示消息数据委托
 *  您可以通过该回调实现：根据传入的 data 初始化消息气泡并进行显示
 */
- (Class)messageController:(MSChatRoomMessageController *)controller onShowMessageData:(MSMessageCellData *)data;

/**
 收到信令消息
 */
- (void)messageController:(MSChatRoomMessageController *)controller onRecieveSignalMessage:(NSArray <MSIMMessage *>*)messages;

/**
 *  控制器点击回调
 *  您可以通过该回调实现：重置 InputControoler，收起键盘。
 */
- (void)didTapInMessageController:(MSChatRoomMessageController *)controller;

/**
 *  点击消息头像委托
 *  您可以通过该回调实现：跳转到对应用户的详细信息界面。
 */
- (void)messageController:(MSChatRoomMessageController *)controller onSelectMessageAvatar:(MSMessageCell *)cell;

/**
 *  点击消息内容委托
 */
- (void)messageController:(MSChatRoomMessageController *)controller onSelectMessageContent:(MSMessageCell *)cell;

/**
 *  显示长按菜单前的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 *  @param view 控制器所在view
 */
- (BOOL)messageController:(MSChatRoomMessageController *)controller willShowMenuInCell:(UIView *)view;

/**
 *  隐藏长按菜单后的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 */
- (void)didHideMenuInMessageController:(MSChatRoomMessageController *)controller;

@end

@interface MSChatRoomMessageController : UITableViewController

@property(nonatomic,weak) id<MSChatRoomMessageControllerDelegate> delegate;

@property(nonatomic,strong) MSGroupInfo *roomInfo;

@property (nonatomic, strong,readonly) NSMutableArray<MSMessageCellData *> *uiMsgs;

- (void)scrollToBottom:(BOOL)animate;

- (void)addSystemTips:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
