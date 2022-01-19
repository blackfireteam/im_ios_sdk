//
//  MSLocationMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/30.
//

#import "MSMessageCell.h"
#import "MSLocationMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSLocationMessageCell : MSMessageCell

@property(nonatomic,strong) UILabel *titleL;

@property(nonatomic,strong) UILabel *detailL;

@property(nonatomic,strong) UIImageView *mapImageView;

@property (nonatomic, strong,readonly) MSLocationMessageCellData *locationData;

@end

NS_ASSUME_NONNULL_END
