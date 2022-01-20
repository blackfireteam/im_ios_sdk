//
//  BFSparkCardCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFSparkCardView.h"

NS_ASSUME_NONNULL_BEGIN

@class MSProfileInfo;
@class BFSparkCardCell;
@protocol BFSparkCardCellDelegate <NSObject>

- (void)winkBtnDidClick:(BFSparkCardCell *)cell;

- (void)chatBtnDidClick:(BFSparkCardCell *)cell;

@end
@interface BFSparkCardCell : BFCardViewCell

@property (nonatomic,strong) UILabel *title;

@property(nonatomic,strong) UIImageView *imageView;

// dislike
@property (nonatomic,strong) UIImageView *dislike;
// like
@property (nonatomic,strong) UIImageView *like;

@property(nonatomic,strong) UIButton *chatBtn;

@property(nonatomic,strong) UIButton *winkBtn;

@property(nonatomic,weak) id<BFSparkCardCellDelegate> delegate;

@property(nonatomic,strong,readonly) MSProfileInfo *user;

- (void)configItem:(MSProfileInfo *)info;

@end

NS_ASSUME_NONNULL_END
