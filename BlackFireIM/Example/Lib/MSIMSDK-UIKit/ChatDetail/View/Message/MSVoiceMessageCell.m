//
//  MSVoiceMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/22.
//

#import "MSVoiceMessageCell.h"
#import "UIView+Frame.h"


@implementation MSVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voice = [[UIImageView alloc] init];
        _voice.animationDuration = 1;
        [self.bubbleView addSubview:_voice];

        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont systemFontOfSize:12];
        _duration.textColor = [UIColor grayColor];
        [self.bubbleView addSubview:_duration];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",self.class);
    [self.voiceData removeObserver:self forKeyPath:@"isPlaying"];
}

- (void)fillWithData:(MSVoiceMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.voiceData = data;
    if (data.voiceElem.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.voiceElem.duration];
    } else {
        _duration.text = @"1\"";    // 显示0秒容易产生误解
    }
    _voice.image = data.voiceImage;
    _voice.animationImages = data.voiceAnimationImages;
    
    //animate
    [self.voiceData addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    self.voiceData.isPlaying = self.voiceData.isPlaying;
    
    if (data.direction == MsgDirectionIncoming) {
        _duration.textAlignment = NSTextAlignmentLeft;
        _duration.textColor = [UIColor grayColor];
    } else {
        _duration.textAlignment = NSTextAlignmentRight;
        _duration.textColor = [UIColor whiteColor];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSNumber *isPlaying = [change objectForKey:NSKeyValueChangeNewKey];
    if ([isPlaying boolValue]) {
        [self.voice startAnimating];
    }else {
        [self.voice stopAnimating];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.voiceData.direction == MsgDirectionIncoming) {
        self.voice.frame = CGRectMake(16, 20-self.voiceData.voiceImage.size.height*0.5, self.voiceData.voiceImage.size.width, self.voiceData.voiceImage.size.height);
        self.duration.frame = CGRectMake(self.voice.maxX+10, 0, 40, 20);
        self.duration.centerY = self.voice.centerY;
    } else {
        self.voice.frame = CGRectMake(0, 20-self.voiceData.voiceImage.size.height*0.5, self.voiceData.voiceImage.size.width, self.voiceData.voiceImage.size.height);
        self.voice.maxX = self.container.width-16;
        self.duration.frame = CGRectMake(0, 0, 40, 20);
        self.duration.centerY = self.voice.centerY;
        self.duration.maxX = self.voice.x-10;
    }
}

@end
