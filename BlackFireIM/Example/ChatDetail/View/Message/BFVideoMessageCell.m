//
//  BFVideoMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/2.
//

#import "BFVideoMessageCell.h"
#import "BFHeader.h"
#import <SDWebImage.h>
#import "UIView+Frame.h"


@implementation BFVideoMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFit;
        _thumb.backgroundColor = [UIColor whiteColor];
        [self.container addSubview:_thumb];
        _thumb.frame = self.container.bounds;
        _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        CGSize playSize = TVideoMessageCell_Play_Size;
        _playIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
        _playIcon.contentMode = UIViewContentModeScaleAspectFit;
        _playIcon.image = [UIImage imageNamed:TUIKitResource(@"play_normal")];
        [self.container addSubview:_playIcon];
        
        _durationL = [[UILabel alloc]init];
        _durationL.textColor = [UIColor whiteColor];
        _durationL.font = [UIFont systemFontOfSize:12];
        [self.container addSubview:_durationL];
        
        _progressL = [[UILabel alloc] init];
        _progressL.textColor = [UIColor whiteColor];
        _progressL.font = [UIFont systemFontOfSize:15];
        _progressL.textAlignment = NSTextAlignmentCenter;
        _progressL.layer.cornerRadius = 5.0;
        _progressL.hidden = YES;
        _progressL.backgroundColor = TImageMessageCell_Progress_Color;
        [_progressL.layer setMasksToBounds:YES];
        [self.container addSubview:_progressL];
        _progressL.frame = self.container.bounds;
        _progressL.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)fillWithData:(BFVideoMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.videoData = data;
    self.durationL.text = [NSString stringWithFormat:@"%02zd:%02zd",data.videoElem.duration/60,data.videoElem.duration%60];
    [self.durationL sizeToFit];
    NSInteger progress = data.videoElem.progress*100;
    self.progressL.text = [NSString stringWithFormat:@"%zd%%",progress];
    [self.progressL setHidden:!(progress > 0 && progress < 100)];
    self.thumb.image = nil;
    if (data.videoElem.coverImage) {
        self.thumb.image = data.videoElem.coverImage;
    }else if ([[NSFileManager defaultManager]fileExistsAtPath:data.videoElem.coverPath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:data.videoElem.coverPath];
        self.thumb.image = image;
        data.videoElem.coverImage = image;
    }else {
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:data.videoElem.coverUrl]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playIcon.center = CGPointMake(self.container.width*0.5, self.container.height*0.5);
    self.durationL.maxY = self.container.height-TVideoMessageCell_Margin_3;
    self.durationL.maxX = self.container.width-TVideoMessageCell_Margin_3;
}

@end
