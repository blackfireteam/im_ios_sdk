//
//  MSSnapImagePreview.m
//  BlackFireIM
//
//  Created by benny wang on 2022/2/22.
//

#import "MSSnapImagePreview.h"
#import <SDWebImage.h>

@interface MSSnapImagePreview()

@property(nonatomic,strong) UIImageView *showImageView;

@end
@implementation MSSnapImagePreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = TController_Background_Color_Dark;
        self.showImageView = [[UIImageView alloc]init];
        [self addSubview:self.showImageView];
    }
    return self;
}

- (void)reloadMessage:(MSIMMessage *)message
{
    [super reloadMessage:message];
    if (message.imageElem.image) {
        self.showImageView.image = message.imageElem.image;
        [self startToCountDown];
    }else if ([[NSFileManager defaultManager]fileExistsAtPath:message.imageElem.path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:message.imageElem.path];
        self.showImageView.image = image;
        message.imageElem.image = image;
        [self startToCountDown];
    }else {
        WS(weakSelf)
        [self.showImageView sd_setImageWithURL:[NSURL URLWithString:message.imageElem.url] placeholderImage:[UIImage imageNamed:TUIKitResource(@"place_holder")] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf startToCountDown];
        }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat imageWidth = self.message.imageElem.width;
    CGFloat imageHeight = self.message.imageElem.height;
    CGFloat showHeight = imageHeight / imageWidth * Screen_Width;
    self.showImageView.frame = CGRectMake(0, Screen_Height * 0.5 - showHeight * 0.5, Screen_Width, showHeight);
    self.scrollView.contentSize = CGSizeMake(Screen_Width, MAX(Screen_Height, showHeight));
}

@end
