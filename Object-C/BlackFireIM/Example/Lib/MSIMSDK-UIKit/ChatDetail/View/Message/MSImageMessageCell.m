//
//  MSImageMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSImageMessageCell.h"
#import "MSIMSDK-UIKit.h"
#import <SDWebImage.h>

@implementation MSImageMessageCell

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

        _progress = [[UILabel alloc] init];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:15];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.layer.cornerRadius = 5.0;
        _progress.hidden = YES;
        _progress.backgroundColor = TImageMessageCell_Progress_Color;
        [_progress.layer setMasksToBounds:YES];
        [self.container addSubview:_progress];
        _progress.frame = self.container.bounds;
        _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (MSImageMessageCellData *)imageData
{
    return (MSImageMessageCellData *)self.messageData;
}

- (void)fillWithData:(MSImageMessageCellData *)data
{
    [super fillWithData:data];
    NSInteger progress = data.message.imageElem.progress*100;
    self.progress.text = [NSString stringWithFormat:@"%zd%%",progress];
    [self.progress setHidden:!(progress > 0 && progress < 100)];
    self.thumb.image = nil;
    if (data.message.imageElem.image) {
        self.thumb.image = data.message.imageElem.image;
    }else if ([[NSFileManager defaultManager]fileExistsAtPath:data.message.imageElem.path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:data.message.imageElem.path];
        self.thumb.image = image;
        data.message.imageElem.image = image;
    }else {
        NSString *thumbUrl = [NSString stringWithFormat:@"%@?imageMogr2/thumbnail/300x/interlace/0",data.message.imageElem.url];
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:thumbUrl] placeholderImage:[UIImage imageNamed:TUIKitResource(@"placeholder_delete")] options:SDWebImageDelayPlaceholder];
    }
}


@end
