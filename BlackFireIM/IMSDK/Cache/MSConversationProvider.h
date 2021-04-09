//
//  MSConversationProvider.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import <Foundation/Foundation.h>
#import "MSIMConversation.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSConversationProvider : NSObject

///单例
+ (instancetype)provider;

- (MSIMConversation *)providerConversation:(NSString *)partner_id;

- (void)updateConversation:(MSIMConversation *)conv;

- (void)updateConversations:(NSArray<MSIMConversation *> *)convs;

- (void)deleteConversation:(NSString *)partner_id;

- (void)clean;

@end

NS_ASSUME_NONNULL_END
