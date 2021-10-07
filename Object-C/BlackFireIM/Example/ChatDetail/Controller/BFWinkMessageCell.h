//
//  MSWinkMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "MSMessageCell.h"
#import <Lottie/Lottie.h>


NS_ASSUME_NONNULL_BEGIN

@interface BFWinkMessageCell : MSMessageCell

@property(nonatomic,strong) LOTAnimationView *animationView;

@property(nonatomic,strong) UILabel *noticeL;

@end

NS_ASSUME_NONNULL_END
