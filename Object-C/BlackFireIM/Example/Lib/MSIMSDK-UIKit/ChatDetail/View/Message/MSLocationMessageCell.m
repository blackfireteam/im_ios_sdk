//
//  MSLocationMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/30.
//

#import "MSLocationMessageCell.h"
#import "MSIMSDK-UIKit.h"
#import <SDWebImage.h>


@implementation MSLocationMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleL = [[UILabel alloc] init];
        _titleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _titleL.font = [UIFont systemFontOfSize:16];
        [self.container addSubview:_titleL];
        
        _detailL = [[UILabel alloc] init];
        _detailL.textColor = [UIColor grayColor];
        _detailL.font = [UIFont systemFontOfSize:13];
        [self.container addSubview:_detailL];
        
        _mapImageView = [[UIImageView alloc] init];
        _mapImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mapImageView.clipsToBounds = YES;
        [self.container addSubview:_mapImageView];
        
        self.container.layer.cornerRadius = 5;
        self.container.layer.masksToBounds = YES;
        self.container.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor clearColor]];
    }
    return self;
}

- (MSLocationMessageCellData *)locationData
{
    return (MSLocationMessageCellData *)self.messageData;
}

- (void)fillWithData:(MSLocationMessageCellData *)data
{
    [super fillWithData:data];
    self.titleL.text = data.locationElem.title;
    self.detailL.text = data.locationElem.detail;
    NSString *mapUrl = [NSString stringWithFormat:@"https://restapi.amap.com/v3/staticmap?location=%f,%f&zoom=%zd&size=550*300&markers=mid,,A:%f,%f&key=%@",data.locationElem.longitude,data.locationElem.latitude,data.locationElem.zoom,data.locationElem.longitude,data.locationElem.latitude,GaodeAPIWebKey];
    [self.mapImageView sd_setImageWithURL:[NSURL URLWithString:mapUrl]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleL.frame = CGRectMake(10, 10, self.container.width - 20, 16);
    self.detailL.frame = CGRectMake(10, self.titleL.maxY + 6, self.titleL.width, 13);
    self.mapImageView.frame = CGRectMake(0, self.detailL.maxY + 6, self.container.width, self.container.height - self.detailL.maxY - 6);
}

@end
