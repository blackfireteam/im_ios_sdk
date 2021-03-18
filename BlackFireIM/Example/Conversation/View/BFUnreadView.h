//
//  BFUnreadView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface BFUnreadView : UIView

@property(nonatomic,strong) UILabel *unReadLabel;

- (void)setNum:(NSInteger)num;

@end

NS_ASSUME_NONNULL_END
