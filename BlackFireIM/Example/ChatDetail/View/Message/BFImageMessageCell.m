//
//  BFImageMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFImageMessageCell.h"
#import "BFHeader.h"
#import <SDWebImage.h>

@implementation BFImageMessageCell

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

- (void)fillWithData:(BFImageMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.imageData = data;
    if (data.thumbImage) {
        self.thumb.image = data.thumbImage;
    }else {
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:data.imageElem.url]];
    }
}

@end
