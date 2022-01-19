//
//  MSChatViewController+More.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "MSChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSChatViewController (More)

///照片
- (void)selectPhotoForSend;

///视频
- (void)selectVideoForSend;

///位置
- (void)selectLocationForSend;

- (void)sendEnotionMessage:(BFFaceCellData *)data;

///切换阅后即焚模式
- (void)selectSnapchatMode;

/// 在阅后即焚模式下选择图片
- (void)selectImageInSnapchatMode;


@end

NS_ASSUME_NONNULL_END
