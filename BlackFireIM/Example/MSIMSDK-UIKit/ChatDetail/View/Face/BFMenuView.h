//
//  BFMenuView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BFMenuView;
@protocol BFMenuViewDelegate <NSObject>

- (void)menuViewDidSendMessage:(BFMenuView *)menuView;

@end

@interface BFMenuView : UIView

@property (nonatomic, strong) UIButton *sendButton;

@property(nonatomic,weak) id<BFMenuViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
