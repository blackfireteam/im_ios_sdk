//
//  BFChatViewController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/17.
//

#import <UIKit/UIKit.h>
#import "MSMessageController.h"
#import "MSInputViewController.h"


NS_ASSUME_NONNULL_BEGIN

@class MSChatViewController;
@class MSIMElem;
@class MSMessageCellData;
@class MSMessageCell;
@class MSInputMoreCell;
@protocol MSChatViewControllerDelegate <NSObject>

///发送新消息时的回调
- (void)chatController:(MSChatViewController *)controller didSendMessage:(MSIMElem *)elem;

///每条新消息在进入气泡展示区之前，都会通过 onNewMessage() 通知给您的代码
///主要用于甄别自定义消息
///如果您返回 nil，MSChatViewController 会认为该条消息非自定义消息，会将其按照普通消息的处理流程进行处理。
///如果您返回一个 MSMessageCellData 类型的对象，MSChatViewController 会在随后触发的 onShowMessageData() 回调里传入您返回的 cellData 对象。
///也就是说，onNewMessage() 负责让您甄别自己的个性化消息，而 onShowMessageData() 回调则负责让您展示这条个性化消息。
- (MSMessageCellData *)chatController:(MSChatViewController *)controller onNewMessage:(MSIMElem *)elem;

///展示自定义个性化消息
///您可以通过重载 onShowMessageData() 改变消息气泡的默认展示逻辑，只需要返回一个自定义的 TUIMessageCell 对象即可。
- (Class)chatController:(MSChatViewController *)controller onShowMessageData:(MSMessageCellData *)cellData;

///点击某一“更多”单元的回调委托
- (void)chatController:(MSChatViewController *)controller onSelectMoreCell:(MSInputMoreCell *)cell;

///点击消息头像回调
- (void)chatController:(MSChatViewController *)controller onSelectMessageAvatar:(MSMessageCell *)cell;

///点击消息内容回调
- (void)chatController:(MSChatViewController *)controller onSelectMessageContent:(MSMessageCell *)cell;


@end

@interface MSChatViewController : UIViewController

@property(nonatomic,copy) NSString *partner_id;

@property(nonatomic,weak) id<MSChatViewControllerDelegate> delegate;

@property(nonatomic,strong,readonly) MSMessageController *messageController;

@property(nonatomic,strong,readonly) MSInputViewController *inputController;

- (void)sendMessage:(MSIMElem *)message;

@end

NS_ASSUME_NONNULL_END
