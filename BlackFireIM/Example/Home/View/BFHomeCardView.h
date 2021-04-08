//
//  BFHomeCardView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFDragCardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFHomeCardView : BFDragCardView

- (void)setAnimationwithDriection:(ContainerDragDirection)direction;

- (void)setImage:(NSString*)imageName title:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
