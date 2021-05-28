//
//  BFImageMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFMessageCell.h"
#import "BFImageMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFImageMessageCell : BFMessageCell


/**
 *  缩略图
 *  用于在消息单元内展示的小图，默认优先展示缩略图，省流量。
 */
@property (nonatomic, strong) UIImageView *thumb;

/**
 *  下载进度标签
 *  图像的下载进度标签，用于向用户展示当前图片的获取进度，优化交互体验。
 */
@property (nonatomic, strong) UILabel *progress;


@property (nonatomic, strong) BFImageMessageCellData *imageData;

- (void)fillWithData:(BFImageMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
