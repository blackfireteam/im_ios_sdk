//
//  MSWinkMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "MSEmotionMessageCell.h"
#import "MSEmotionMessageCellData.h"
#import "MSIMSDK-UIKit.h"


@implementation MSEmotionMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _animationView = [[LOTAnimationView alloc]init];
        [self.container addSubview:_animationView];
        _animationView.frame = self.container.bounds;
        _animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (MSEmotionMessageCellData *)emotionData
{
    return (MSEmotionMessageCellData *)self.messageData;
}

- (void)fillWithData:(MSEmotionMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TUIKitFace" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *emotionName = [MSHelper emoteionName:data.message.emotionElem.emotionID];
    [self.animationView setAnimationNamed:[NSString stringWithFormat:@"emotion/%@",emotionName] inBundle:resourceBundle];
    self.animationView.loopAnimation = YES;
    [self.animationView play];
}

@end
