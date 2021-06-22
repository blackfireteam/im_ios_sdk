//
//  MSWinkMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFWinkMessageCell.h"
#import "BFWinkMessageCellData.h"
#import "MSHeader.h"


@implementation BFWinkMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _animationView = [LOTAnimationView animationNamed:@"wink"];
        _animationView.loopAnimation = YES;
        [self.container addSubview:_animationView];
        _animationView.frame = self.container.bounds;
        _animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_animationView play];
        
        _noticeL = [[UILabel alloc]init];
        _noticeL.font = [UIFont systemFontOfSize:12];
        _noticeL.text = @"like";
        _noticeL.textAlignment = NSTextAlignmentRight;
        _noticeL.textColor = [UIColor d_systemGrayColor];
        [self.container addSubview:_noticeL];
    }
    return self;
}

- (void)fillWithData:(BFWinkMessageCellData *)data
{
    //set data
    [super fillWithData:data];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.noticeL.frame = CGRectMake(self.container.width-50, self.container.height-15, 50, 15);
}

@end
