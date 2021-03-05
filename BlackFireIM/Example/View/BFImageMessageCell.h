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

/**
 *  图像消息单元消息源
 *  imageData 中存放了图像路径，图像原图、大图、缩略图，以及三种图像对应的下载进度、上传进度等各种图像消息单元所需信息。
 *  详细信息请参考 Section\Chat\CellData\TUIIamgeMessageCellData.h
 */
@property (nonatomic, strong) BFImageMessageCellData *imageData;

/**
 *  填充数据
 *  根据 data 设置图像消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(BFImageMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
