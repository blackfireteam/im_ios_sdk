//
//  MSMenuView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSMenuView;
@protocol MSMenuViewDelegate <NSObject>

- (void)menuViewDidSendMessage:(MSMenuView *)menuView;

@end

@interface MSMenuView : UIView

@property (nonatomic, strong) UIButton *sendButton;

@property(nonatomic,weak) id<MSMenuViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
