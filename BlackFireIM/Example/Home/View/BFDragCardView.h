//
//  BFDragCardView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "BFDragConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFDragCardView : UIView

@property (nonatomic,assign) CGAffineTransform originTransForm;

@property (nonatomic,strong) BFDragConfig *config;

- (void)dragCardViewLayoutSubviews;

- (void)startAnimatingForDirection:(ContainerDragDirection)direction;

@end

NS_ASSUME_NONNULL_END
