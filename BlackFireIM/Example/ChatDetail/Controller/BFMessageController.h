//
//  messageController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFMessageController : UITableViewController

@property(nonatomic,copy) NSString *partner_id;

- (void)scrollToBottom:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
