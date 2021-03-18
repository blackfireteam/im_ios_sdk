//
//  BFConversationListViewModel.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFConversationListViewModel.h"
#import "MSIMSDK.h"
#import "UIImage+BFKit.h"


@interface BFConversationListViewModel()

@property (nonatomic, strong) NSMutableArray *localConvList;

@end
@implementation BFConversationListViewModel

- (instancetype)init
{
    if (self = [super init]) {
        self.localConvList = [NSMutableArray array];
        [self loadConversation];
    }
    return self;
}

- (void)loadConversation
{
    WS(weakSelf)
    [[MSIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<MSIMConversation *> * _Nonnull convs, NSInteger nexSeq, BOOL isFinished) {
        [weakSelf updateConversation: convs];
        } fail:^(NSInteger code, NSString * _Nonnull desc) {
            
    }];
}

- (void)updateConversation:(NSArray *)convList
{
    // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
    for (NSInteger i = 0; i < convList.count; i++) {
        MSIMConversation *conv = convList[i];
        BOOL isExist = NO;
        for (NSInteger j = 0; i < self.localConvList.count; j++) {
            MSIMConversation *localConv = self.localConvList[j];
            if ([localConv.conversation_id isEqualToString:conv.conversation_id]) {
                [self.localConvList replaceObjectAtIndex:j withObject:conv];
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [self.localConvList addObject:conv];
        }
    }
    // 更新 cell data
    NSMutableArray *dataList = [NSMutableArray array];
    for (MSIMConversation *conv in self.localConvList) {
        BFConversationCellData *data = [[BFConversationCellData alloc]init];
        data.conv = conv;
        data.title = conv.userInfo.nick_name;
        data.subTitle = [self getLastDisplayString:conv];
        data.time = [NSDate dateWithTimeIntervalSince1970:conv.time/1000/1000];
        if (conv.chat_type == BFIM_CHAT_TYPE_C2C) {
            data.avatarImage = [UIImage bf_imageNamed:@"default_c2c_head"];
        }else {
            data.avatarImage = [UIImage bf_imageNamed:@"default_group_head"];
        }
        [dataList addObject:data];
    }
    // UI 会话列表根据 lastMessage 时间戳重新排序
    [self sortDataList:dataList];
    self.dataList = dataList;
}

- (NSMutableAttributedString *)getLastDisplayString:(MSIMConversation *)conv
{
    NSString *lastMsgStr = conv.show_msg.displayStr;
    if (lastMsgStr.length == 0) {
        return nil;
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:lastMsgStr];
    [attr setAttributes:@{NSForegroundColorAttributeName: [UIColor d_systemGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(0, attr.length)];
    return attr;
}

- (void)sortDataList:(NSMutableArray<BFConversationCellData *> *)dataList
{
    // 按时间排序，最近会话在上
    [dataList sortUsingComparator:^NSComparisonResult(BFConversationCellData *obj1, BFConversationCellData *obj2) {
        return [obj2.time compare:obj1.time];
    }];
}

- (void)removeData:(BFConversationCellData *)data
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.dataList];
    [list removeObject:data];
    self.dataList = list;
    for (MSIMConversation *conv in self.localConvList) {
        if ([conv.conversation_id isEqualToString:data.conv.conversation_id]) {
            [self.localConvList removeObject:conv];
            break;
        }
    }
    [[MSIMManager sharedInstance] deleteConversation:data.conv succ:^{
        
    } failed:^(NSInteger code, NSString * _Nonnull desc) {
        
    }];
}

@end

