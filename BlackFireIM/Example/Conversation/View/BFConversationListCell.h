//
//  BFConversationListCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import <UIKit/UIKit.h>
#import "BFUnreadView.h"
#import "BFConversationCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFConversationListCell : UITableViewCell

@property(nonatomic,strong) UIImageView *headImageView;

@property(nonatomic,strong) UILabel *titleLabel;

@property(nonatomic,strong) UILabel *subTitleLabel;

@property(nonatomic,strong) UILabel *timeLabel;

@property(nonatomic,strong) UIImageView *goldIcon;

@property(nonatomic,strong) UIImageView *matchIcon;

@property(nonatomic,strong) UIImageView *verifyIcon;

@property(nonatomic,strong) BFUnreadView *unReadView;

- (void)configWithData:(BFConversationCellData *)convData;

@end

NS_ASSUME_NONNULL_END
