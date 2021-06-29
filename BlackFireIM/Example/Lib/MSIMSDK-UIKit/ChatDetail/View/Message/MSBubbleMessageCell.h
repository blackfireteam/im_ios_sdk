//
//  MSBubbleMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSMessageCell.h"
#import "MSBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSBubbleMessageCell : MSMessageCell

/**
 *  气泡图像视图，即消息的气泡图标，在 UI 上作为气泡的背景板包裹消息信息内容。
 */
@property (nonatomic, strong) UIImageView *bubbleView;

/**
 *  气泡单元数据源
 *  气泡单元数据源中存放了气泡的各类图标，比如接收图标（正常与高亮）、发送图标（正常与高亮）。
 *  并能根据具体的发送、接收状态选择相应的图标进行显示。
 */
@property (nonatomic, strong) MSBubbleMessageCellData *bubbleData;

/**
 *  填充数据
 *  根据 data 设置气泡消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(MSBubbleMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
