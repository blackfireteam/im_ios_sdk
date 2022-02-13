//
//  MSChatRoomController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/10/28.
//

#import <UIKit/UIKit.h>
#import "MSChatRoomMessageController.h"
#import "MSInputViewController.h"


NS_ASSUME_NONNULL_BEGIN

@class MSChatRoomController;
@class MSIMMessage;
@class MSMessageCellData;
@class MSMessageCell;
@class MSInputMoreCell;
@class MSGroupInfo;
@protocol MSChatRoomControllerDelegate <NSObject>

///发送新消息时的回调
- (void)chatController:(MSChatRoomController *)controller didSendMessage:(MSIMMessage *)message;

///每条新消息在进入气泡展示区之前，都会通知给您
///主要用于甄别自定义消息
///如果您返回 nil，MSChatViewController 会认为该条消息非自定义消息，会将其按照普通消息的处理流程进行处理。
///如果您返回一个 MSMessageCellData 类型的对象，MSChatViewController 会在随后触发的 onShowMessageData() 回调里传入您返回的 cellData 对象。
///也就是说，onNewMessage() 负责让您甄别自己的个性化消息，而 onShowMessageData() 回调则负责让您展示这条个性化消息。
- (MSMessageCellData *)chatController:(MSChatRoomController *)controller prepareForMessage:(MSIMMessage *)message;

///展示自定义个性化消息
///您可以通过重载 onShowMessageData() 改变消息气泡的默认展示逻辑，只需要返回一个自定义的 TUIMessageCell 对象即可。
- (Class)chatController:(MSChatRoomController *)controller onShowMessageData:(MSMessageCellData *)cellData;

///点击某一“更多”单元的回调委托
- (void)chatController:(MSChatRoomController *)controller onSelectMoreCell:(MSInputMoreCell *)cell;

///点击消息头像回调
- (void)chatController:(MSChatRoomController *)controller onSelectMessageAvatar:(MSMessageCell *)cell;

///点击消息内容回调
- (void)chatController:(MSChatRoomController *)controller onSelectMessageContent:(MSMessageCell *)cell;

@end

@interface MSChatRoomController : UIViewController

@property(nonatomic,strong) MSGroupInfo *roomInfo;

@property(nonatomic,weak) id<MSChatRoomControllerDelegate> delegate;

@property(nonatomic,strong,readonly) MSChatRoomMessageController *messageController;

@property(nonatomic,strong,readonly) MSInputViewController *inputController;

- (void)sendMessage:(MSIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
