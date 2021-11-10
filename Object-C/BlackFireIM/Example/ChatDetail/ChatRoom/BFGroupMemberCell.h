//
//  BFGroupMemberCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/8.
//

#import <UIKit/UIKit.h>
#import <MSIMSDK/MSIMSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface BFGroupMemberCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property(nonatomic,strong) UILabel *idL;

@property(nonatomic,strong) UILabel *muteL;

@property(nonatomic,strong) MSGroupMemberItem *info;

@end

NS_ASSUME_NONNULL_END
