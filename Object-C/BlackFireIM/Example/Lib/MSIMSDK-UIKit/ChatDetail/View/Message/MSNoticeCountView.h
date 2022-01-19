//
//  MSNoticeCountView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MSNoticeCountViewDelegate <NSObject>

- (void)countViewDidTap;

@end
@interface MSNoticeCountView : UIView

@property(nonatomic,strong) UIButton *countBtn;

@property(nonatomic,weak) id<MSNoticeCountViewDelegate> delegate;

- (void)increaseCount:(NSInteger)count;

- (void)cleanCount;

@end

NS_ASSUME_NONNULL_END
