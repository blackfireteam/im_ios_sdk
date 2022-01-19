//
//  MSLocationListCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/29.
//

#import <UIKit/UIKit.h>
#import "MSLocationInfo.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSLocationListCell : UITableViewCell

@property(nonatomic,strong) UILabel *titleL;

@property(nonatomic,strong) UILabel *addressL;

@property(nonatomic,strong) UIImageView *checkIcon;

- (void)configCell:(MSLocationInfo *)info;

@end

NS_ASSUME_NONNULL_END
