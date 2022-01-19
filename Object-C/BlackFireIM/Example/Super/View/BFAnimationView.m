//
//  BFAnimationView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/22.
//

#import "BFAnimationView.h"
#import "MSIMSDK-UIKit.h"
#import <Lottie/Lottie.h>


@implementation BFAnimationView

+ (void)showAnimation:(NSString *)name size:(CGSize)size isLoop:(BOOL)loop
{
    BFAnimationView *aniView = [[BFAnimationView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    [[UIApplication sharedApplication].keyWindow addSubview:aniView];
    
    LOTAnimationView *lotView = [LOTAnimationView animationNamed:name];
    lotView.loopAnimation = loop;
    lotView.size = size;
    lotView.center = aniView.center;
    [aniView addSubview:lotView];
    lotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak BFAnimationView *weakAniView = aniView;
    [lotView playWithCompletion:^(BOOL animationFinished) {
        [weakAniView removeFromSuperview];
    }];
}

- (void)dealloc
{
    MSLog(@"BFAnimationView dealloc");
}


@end
