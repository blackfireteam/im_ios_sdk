//
//  BFSystemMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import "BFMessageCell.h"
#import "BFSystemMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFSystemMessageCell : BFMessageCell

/**
 *  系统消息标签
 *  用于展示系统消息的内容。例如：“您撤回了一条消息”。
 */
@property (nonatomic,strong,readonly) UILabel *messageLabel;

/**
 *  系统消息单元数据源
 *  消息源中存放了系统消息的内容、消息字体以及消息颜色。
 *  详细信息请参考 Section\Chat\CellData\TUISystemMessageCellData.h
 */
@property (nonatomic,strong,readonly) BFSystemMessageCellData *systemData;

/**
 *  填充数据
 *  根据 data 设置系统消息的数据
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(BFSystemMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
