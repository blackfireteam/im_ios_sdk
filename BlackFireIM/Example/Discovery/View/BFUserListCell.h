//
//  BFUserListCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import <UIKit/UIKit.h>
#import "MSProfileInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFUserListCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property(nonatomic,strong) UIImageView *liveIcon;

- (void)configWithInfo:(MSProfileInfo *)info;

@end

NS_ASSUME_NONNULL_END
