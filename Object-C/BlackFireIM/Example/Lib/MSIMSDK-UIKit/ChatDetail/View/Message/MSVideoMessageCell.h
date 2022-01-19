//
//  MSVideoMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/2.
//

#import "MSMessageCell.h"
#import "MSVideoMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSVideoMessageCell : MSMessageCell

/** 视频缩略图*/
@property (nonatomic, strong) UIImageView *thumb;

/** 视频时长标签*/
@property(nonatomic,strong) UILabel *durationL;

/** 播放图标*/
@property(nonatomic,strong) UIImageView *playIcon;

/** 视频上传进度标签*/
@property(nonatomic,strong) UILabel *progressL;

@property (nonatomic, strong,readonly) MSVideoMessageCellData *videoData;

@end

NS_ASSUME_NONNULL_END
