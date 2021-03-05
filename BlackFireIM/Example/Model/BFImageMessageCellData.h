//
//  BFImageMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFImageMessageCellData : BFMessageCellData

/**
 *  图像缩略图
 */
@property (nonatomic, strong) UIImage *thumbImage;

/**
 *  图像原图
 */
@property (nonatomic, strong) UIImage *originImage;

@property(nonatomic,strong) BFIMImageElem *imageElem;

/**
 *  上传（发送）进度
 */
@property (nonatomic, assign) NSUInteger uploadProgress;

@end

NS_ASSUME_NONNULL_END
