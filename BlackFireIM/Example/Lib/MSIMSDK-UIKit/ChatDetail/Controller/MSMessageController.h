//
//  messageController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSMessageController;
@class MSMessageCell;
@class MSMessageCellData;
@class MSIMElem;
@protocol MSMessageControllerDelegate <NSObject>


/**
 *  收到新消息的函数委托
 */
- (MSMessageCellData *)messageController:(MSMessageController *)controller onNewMessage:(MSIMElem *)data;

/**
 *  显示消息数据委托
 *  您可以通过该回调实现：根据传入的 data 初始化消息气泡并进行显示
 */
- (Class)messageController:(MSMessageController *)controller onShowMessageData:(MSMessageCellData *)data;

/**
 *  控制器点击回调
 *  您可以通过该回调实现：重置 InputControoler，收起键盘。
 */
- (void)didTapInMessageController:(MSMessageController *)controller;

/**
 *  点击消息头像委托
 *  您可以通过该回调实现：跳转到对应用户的详细信息界面。
 */
- (void)messageController:(MSMessageController *)controller onSelectMessageAvatar:(MSMessageCell *)cell;

/**
 *  点击消息内容委托
 */
- (void)messageController:(MSMessageController *)controller onSelectMessageContent:(MSMessageCell *)cell;

/**
 *  显示长按菜单前的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 *  @param view 控制器所在view
 */
- (BOOL)messageController:(MSMessageController *)controller willShowMenuInCell:(UIView *)view;

/**
 *  隐藏长按菜单后的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 */
- (void)didHideMenuInMessageController:(MSMessageController *)controller;

@end

@interface MSMessageController : UITableViewController

@property(nonatomic,weak) id<MSMessageControllerDelegate> delegate;

@property(nonatomic,copy) NSString *partner_id;

@property (nonatomic, strong,readonly) NSMutableArray<MSMessageCellData *> *uiMsgs;

- (void)scrollToBottom:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
