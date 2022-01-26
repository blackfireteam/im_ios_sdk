//
//  MSFlashImageMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2022/1/25.
//

#import "MSFlashImageMessageCell.h"
#import "MSIMSDK-UIKit.h"


@implementation MSFlashImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _maskView = [[UIImageView alloc] init];
        _maskView.layer.cornerRadius = 5.0;
        [_maskView.layer setMasksToBounds:YES];
        _maskView.contentMode = UIViewContentModeScaleAspectFill;
        [self.container addSubview:_maskView];
        _maskView.frame = self.container.bounds;
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _fireIcon = [[UIImageView alloc]init];
        [self.container addSubview:_fireIcon];
        
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

- (MSFlashImageMessageCellData *)flashImageData
{
    return (MSFlashImageMessageCellData *)self.flashImageData;
}

- (void)fillWithData:(MSFlashImageMessageCellData *)data
{
    [super fillWithData:data];
    NSInteger progress = data.flashElem.progress*100;
    self.progressL.text = [NSString stringWithFormat:@"%zd%%",progress];
    [self.progressL setHidden:!(progress > 0 && progress < 100)];
    BOOL isRead = data.flashElem.isSelf ? data.flashElem.from_see : data.flashElem.to_see;
    self.maskView.image = isRead ? [UIImage imageNamed:TUIKitResource(@"flashImg_sel")] : [UIImage imageNamed:TUIKitResource(@"flashImg_nor")];
    self.fireIcon.image = isRead ? [UIImage imageNamed:TUIKitResource(@"flashFire_sel")] : [UIImage imageNamed:TUIKitResource(@"flashFire_nor")];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.fireIcon.frame = CGRectMake(self.container.width * 0.5 - 25, self.container.height * 0.5 - 25, 50, 50);
}

@end
