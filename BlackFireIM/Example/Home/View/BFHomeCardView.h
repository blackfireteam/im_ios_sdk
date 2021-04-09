//
//  BFHomeCardView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFDragCardView.h"
#import "MSProfileInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFHomeCardView : BFDragCardView

- (void)setAnimationwithDriection:(ContainerDragDirection)direction;

- (void)configItem:(MSProfileInfo *)info;


@end

NS_ASSUME_NONNULL_END
