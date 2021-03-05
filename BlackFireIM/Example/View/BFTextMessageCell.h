//
//  BFTextMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFBubbleMessageCell.h"
#import "BFTextMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFTextMessageCell : BFBubbleMessageCell

/**
 *  内容标签
 *  用于展示文本消息的内容。
 */
@property (nonatomic, strong) UILabel *content;

/**
 *  文本消息单元数据源
 *  数据源内存放了文本消息的内容信息、消息字体、消息颜色、并存放了发送、接收两种状态下的不同字体颜色。
 */
@property (nonatomic, strong) BFTextMessageCellData *textData;

/**
 *  填充数据
 *  根据 data 设置文本消息的数据。
 *
 *  @param  data    填充数据需要的数据源
 */
- (void)fillWithData:(BFTextMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
