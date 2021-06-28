//
//  BFVoiceChatController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/6/27.
//

#import "BFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFVoiceChatController : BFBaseViewController

- (void)showWithPartner_id:(NSString *)partner_id bySelf:(BOOL)isSelf;

- (void)dismissBySelf:(BOOL)isSelf;

@end

NS_ASSUME_NONNULL_END
