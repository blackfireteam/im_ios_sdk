//
//  BFNaviBarIndicatorView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFNaviBarIndicatorView : UIView

@property(nonatomic,strong) UIActivityIndicatorView *indicator;

@property(nonatomic,strong) UILabel *label;

- (void)setTitle:(NSString *)title;

- (void)startAnimating;

- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
