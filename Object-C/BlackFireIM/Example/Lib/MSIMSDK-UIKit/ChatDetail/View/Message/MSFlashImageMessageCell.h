//
//  MSFlashImageMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2022/1/25.
//

#import "MSMessageCell.h"
#import "MSFlashImageMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSFlashImageMessageCell : MSMessageCell

@property (nonatomic, strong) UIImageView *maskView;

@property(nonatomic,strong) UIImageView *fireIcon;

@property (nonatomic, strong) UILabel *progressL;


@property (nonatomic, strong,readonly) MSFlashImageMessageCellData *flashImageData;

@end

NS_ASSUME_NONNULL_END
