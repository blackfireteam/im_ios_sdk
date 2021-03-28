//
//  MSConversationProvider.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import "MSConversationProvider.h"
#import "MSDBConversationStore.h"


@interface MSConversationProvider()

@property(nonatomic,strong) NSCache *mainCache;
@property(nonatomic,strong) MSDBConversationStore *store;

@end
@implementation MSConversationProvider

///单例
static MSConversationProvider *instance;
+ (instancetype)provider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[MSConversationProvider alloc]init];
    });
    return instance;
}

- (NSCache *)mainCache
{
    if (!_mainCache) {
        _mainCache = [[NSCache alloc] init];
        _mainCache.countLimit = 1000; // 限制个数，默认是0，无限空间
        _mainCache.totalCostLimit = 0; // 设置大小设置，默认是0，无限空间
        _mainCache.name = @"conv_cache";
    }
    return _mainCache;
}

- (MSDBConversationStore *)store
{
    if (!_store) {
        _store = [[MSDBConversationStore alloc]init];
    }
    return _store;
}

- (MSIMConversation *)providerConversation:(NSString *)partner_id
{
    if (!partner_id) return nil;
    NSString *conv_id = [NSString stringWithFormat:@"c2c_%@",partner_id];
    MSIMConversation *conv = [self.mainCache objectForKey:conv_id];
    if (conv) {
        return conv;
    }
    MSIMConversation *con = [self.store searchConversation:conv_id];
    if (con) {
        [self.mainCache setObject:con forKey:conv_id];
        return con;
    }
    return nil;
}

- (void)updateConversation:(MSIMConversation *)conv
{
    if (!conv) return;
    [self.mainCache setObject:conv forKey:conv.conversation_id];
    [self.store addConversation:conv];
}

- (void)updateConversations:(NSArray<MSIMConversation *> *)convs
{
    for (MSIMConversation *con in convs) {
        [self updateConversation:con];
    }
}

///删除会话
- (void)deleteConversation:(NSString *)conv_id
{
    if (!conv_id) return;
    [self.mainCache removeObjectForKey:conv_id];
    [self.store deleteConversation:conv_id];
}

- (void)clean
{
    [self.mainCache removeAllObjects];
}

@end
