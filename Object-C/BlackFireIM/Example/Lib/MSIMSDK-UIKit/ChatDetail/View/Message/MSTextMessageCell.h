//
//  MSTextMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSBubbleMessageCell.h"
#import "MSTextMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSTextMessageCell : MSBubbleMessageCell

/**
 *  内容标签
 *  用于展示文本消息的内容。
 */
@property (nonatomic, strong) UILabel *content;



/**
 *  文本消息单元数据源
 *  数据源内存放了文本消息的内容信息、消息字体、消息颜色、并存放了发送、接收两种状态下的不同字体颜色。
 */
@property (nonatomic, strong,readonly) MSTextMessageCellData *textData;


@end

NS_ASSUME_NONNULL_END
