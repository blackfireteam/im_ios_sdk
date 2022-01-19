//
//  BFSelectDepartView.h
//  BlackFireIM
//
//  Created by benny wang on 2022/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFSelectorView : UIView

/// type: 0.选择部门 1.选择办公所在地
+ (void)showSelectView:(NSInteger)type
          submitAction:(nullable void(^)(NSString *text))submitAction
                cancel:(nullable void(^)(void))cancelAction;
@end

NS_ASSUME_NONNULL_END
