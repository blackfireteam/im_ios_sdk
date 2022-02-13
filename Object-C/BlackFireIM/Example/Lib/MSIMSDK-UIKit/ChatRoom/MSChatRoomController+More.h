//
//  MSChatRoomController+More.h
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import "MSChatRoomController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSChatRoomController (More)

///照片
- (void)selectPhotoForSend;

///视频
- (void)selectVideoForSend;

///位置
- (void)selectLocationForSend;

- (void)sendEnotionMessage:(BFFaceCellData *)data;

@end

NS_ASSUME_NONNULL_END
