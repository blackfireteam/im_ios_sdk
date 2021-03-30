//
//  BFNoticeCountView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BFNoticeCountViewDelegate <NSObject>

- (void)countViewDidTap;

@end
@interface BFNoticeCountView : UIView

@property(nonatomic,strong) UIButton *countBtn;

@property(nonatomic,weak) id<BFNoticeCountViewDelegate> delegate;

- (void)increaseCount;

- (void)cleanCount;

@end

NS_ASSUME_NONNULL_END
