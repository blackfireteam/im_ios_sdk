//
//  MSUnreadView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/5/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSUnreadView : UIView

@property(nonatomic,strong) UILabel *unReadLabel;

- (void)setNum:(NSInteger)num;

@end

NS_ASSUME_NONNULL_END
