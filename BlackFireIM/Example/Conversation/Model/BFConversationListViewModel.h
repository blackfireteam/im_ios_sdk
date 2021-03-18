//
//  BFConversationListViewModel.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import <Foundation/Foundation.h>
#import "BFConversationListCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFConversationListViewModel : NSObject

@property(nonatomic,strong) NSArray<BFConversationCellData *> *dataList;

///加载会话
- (void)loadConversation;

///删除会话
- (void)removeData:(BFConversationCellData *)data;


@end

NS_ASSUME_NONNULL_END
