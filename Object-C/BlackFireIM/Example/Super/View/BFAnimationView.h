//
//  BFAnimationView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFAnimationView : UIView

+ (void)showAnimation:(NSString *)name size:(CGSize)size isLoop:(BOOL)loop;

@end

NS_ASSUME_NONNULL_END
