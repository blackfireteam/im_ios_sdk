//
//  messageController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BFMessageController;
@class BFMessageCell;
@protocol BFMessageControllerDelegate <NSObject>

/**
 *  控制器点击回调
 *  您可以通过该回调实现：重置 InputControoler，收起键盘。
 */
- (void)didTapInMessageController:(BFMessageController *)controller;

/**
 *  点击消息头像委托
 *  您可以通过该回调实现：跳转到对应用户的详细信息界面。
 */
- (void)messageController:(BFMessageController *)controller onSelectMessageAvatar:(BFMessageCell *)cell;

/**
 *  点击消息内容委托
 */
- (void)messageController:(BFMessageController *)controller onSelectMessageContent:(BFMessageCell *)cell;

/**
 *  显示长按菜单前的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 *  @param view 控制器所在view
 */
- (BOOL)messageController:(BFMessageController *)controller willShowMenuInCell:(UIView *)view;

/**
 *  隐藏长按菜单后的回调函数
 *  您可以根据您的需求个性化实现该委托函数。
 *
 *  @param controller 委托者，消息控制器
 */
- (void)didHideMenuInMessageController:(BFMessageController *)controller;

@end

@interface BFMessageController : UITableViewController

@property(nonatomic,weak) id<BFMessageControllerDelegate> delegate;

@property(nonatomic,copy) NSString *partner_id;

@property (nonatomic, strong,readonly) NSMutableArray *uiMsgs;

- (void)scrollToBottom:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
