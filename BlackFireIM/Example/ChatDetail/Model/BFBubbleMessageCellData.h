//
//  BFBubbleMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFBubbleMessageCellData : BFMessageCellData

/**
 *  气泡图标（正常）
 *  气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
 */
@property(nonatomic,strong) UIImage *bubble;

/**
 *  气泡图标（高亮）
 *  气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
 */
@property(nonatomic,strong) UIImage *highlightedBubble;


/**
 *  发送气泡图标（正常）
 *  气泡的发送图标，当气泡消息单元为发送时赋值给 bubble。
 */
@property(nonatomic,class) UIImage *outgoingBubble;

/**
 *  发送气泡图标（高亮）
 *  气泡的发送图标（高亮），当气泡消息单元为发送时赋值给 highlightedBubble。
 */
@property(nonatomic,class) UIImage *outgoingHighlightedBubble;

/**
 *  接收气泡图标（正常）
 *  气泡的接收图标，当气泡消息单元为接收时赋值给 bubble。
 */
@property(nonatomic,class) UIImage *incommingBubble;

/**
 *  接收气泡图标（高亮）
 *  气泡的接收图标，当气泡消息单元为接收时赋值给 highlightedBubble。
 */
@property(nonatomic,class) UIImage *incommingHighlightedBubble;


@end

NS_ASSUME_NONNULL_END
