//
//  BFInputViewController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "BFBaseViewController.h"
#import "BFInputBarView.h"
#import "BFChatMoreView.h"
#import "BFFaceView.h"
#import "BFMenuView.h"


@class BFInputViewController;
NS_ASSUME_NONNULL_BEGIN
/**
 *  控制器的回调委托。
 *  通常由各个视图（InputBar、MoreView 等）中的回调函数进一步调用。实现功能的分层与逐步细化。
 */
@protocol BFInputViewControllerDelegate <NSObject>

/**
 *  当前 InputController 高度改变时的回调。
 *  一般由 InputBar 中的高度改变回调进一步调用。
 *  您可以通过该回调实现：根据改变的高度调整控制器内各个组件的 UI 布局。
 *
 *  @param  inputController 委托者，当前参与交互的视图控制器。
 *  @param height 改变高度的具体数值（偏移量）。
 */
- (void)inputController:(BFInputViewController *)inputController didChangeHeight:(CGFloat)height;

/**
 *  当前 InputCOntroller 发送信息时的回调。
 */
- (void)inputController:(BFInputViewController *)inputController didSendMessage:(NSString *)msg;

/**
 *  有 @ 字符输入
 */
- (void)inputControllerDidInputAt:(BFInputViewController *)inputController;

/**
 *  有 @xxx 字符删除
 */
- (void)inputController:(BFInputViewController *)inputController didDeleteAt:(NSString *)atText;


/// 点击拍照，照片等更多功能
- (void)inputController:(BFInputViewController *)inputController didSelectMoreCell:(BFInputMoreCell *)cell;

@end

@interface BFInputViewController : BFBaseViewController

@property(nonatomic,strong) BFInputBarView *inputBar;

@property (nonatomic,strong) BFFaceView *faceView;

@property (nonatomic, strong) BFMenuView *menuView;

@property (nonatomic, strong) BFChatMoreView *moreView;

@property(nonatomic,weak) id<BFInputViewControllerDelegate> delegate;

/**
 *  重置当前输入控制器。
 *  如果当前有表情视图或者“更多“视图正在显示，则收起相应视图，并将当前状态设置为 Input_Status_Input。
 *  即无论当前 InputController 处于何种状态，都将其重置为初始化后的状态。
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
