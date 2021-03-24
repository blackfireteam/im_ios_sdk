//
//  BFUserListCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import <UIKit/UIKit.h>
#import "MSProfileInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFUserListCell : UITableViewCell

/**
 *  头像视图
 */
@property (nonatomic, strong) UIImageView *avatarView;

/**
 *  昵称标签
 */
@property (nonatomic, strong) UILabel *nameLabel;

- (void)configWithInfo:(MSProfileInfo *)info;

@end

NS_ASSUME_NONNULL_END
