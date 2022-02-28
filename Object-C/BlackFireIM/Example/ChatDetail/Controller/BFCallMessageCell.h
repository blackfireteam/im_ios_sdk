//
//  MSCallMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/8/18.
//

#import "MSTextMessageCell.h"
#import "BFCallMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFCallMessageCell : MSBubbleMessageCell

@property(nonatomic,strong) UIImageView *icon;

@property(nonatomic,strong) UILabel *titleL;

@property (nonatomic, strong,readonly) BFCallMessageCellData *callData;

@end

NS_ASSUME_NONNULL_END
