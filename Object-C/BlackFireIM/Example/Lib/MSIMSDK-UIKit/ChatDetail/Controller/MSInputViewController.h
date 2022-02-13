//
//  MSInputViewController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>
#import "MSInputBarView.h"
#import "MSChatMoreView.h"
#import "MSFaceView.h"
#import "MSMenuView.h"
#import <MSIMSDK/MSIMSDK.h>


@class MSInputViewController;

NS_ASSUME_NONNULL_BEGIN
/**
 *  控制器的回调委托。
 *  通常由各个视图（InputBar、MoreView 等）中的回调函数进一步调用。实现功能的分层与逐步细化。
 */
@protocol MSInputViewControllerDelegate <NSObject>

/**
 *  当前 InputController 高度改变时的回调。
 *  一般由 InputBar 中的高度改变回调进一步调用。
 *  您可以通过该回调实现：根据改变的高度调整控制器内各个组件的 UI 布局。
 *
 *  @param  inputController 委托者，当前参与交互的视图控制器。
 *  @param height 改变高度的具体数值（偏移量）。
 */
- (void)inputController:(MSInputViewController *)inputController didChangeHeight:(CGFloat)height;

/**
 *  当前 InputCOntroller 发送文本消息时的回调。
 */
- (void)inputController:(MSInputViewController *)inputController didSendTextMessage:(NSString *)msg;

/**
 *  当前 InputCOntroller 发送语音信息时的回调。
 */
- (void)inputController:(MSInputViewController *)inputController didSendVoiceMessage:(NSString *)filePath;

/**
 *  输入框中内容发生变化时的回调
 */
- (void)inputController:(MSInputViewController *)inputController contentDidChanged:(NSString *)text;

/**
 *  有 @ 字符输入
 */
- (void)inputControllerDidInputAt:(MSInputViewController *)inputController;

/**
 *  有 @xxx 字符删除
 */
- (void)inputController:(MSInputViewController *)inputController didDeleteAt:(NSString *)atText;


/// 点击拍照，照片等更多功能
- (void)inputController:(MSInputViewController *)inputController didSelectMoreCell:(MSInputMoreCell *)cell;

/// 点击阅后即焚模式下的图片
- (void)inputControllerDidSelectSnapchatImage:(MSInputViewController *)inputController;

/// 点击发送自定义表情
- (void)inputController:(MSInputViewController *)inputController didSendEmotion:(BFFaceCellData *)data;

@end

@interface MSInputViewController : UIViewController

@property(nonatomic,strong) MSInputBarView *inputBar;

@property (nonatomic,strong) MSFaceView *faceView;

@property (nonatomic, strong) MSMenuView *menuView;

@property (nonatomic, strong) MSChatMoreView *moreView;


- (instancetype)initWithChatType:(MSIMAChatType)type delegate:(id<MSInputViewControllerDelegate>)delegate;

/**
 *  重置当前输入控制器。
 *  如果当前有表情视图或者“更多“视图正在显示，则收起相应视图，并将当前状态设置为 Input_Status_Input。
 *  即无论当前 InputController 处于何种状态，都将其重置为初始化后的状态。
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
