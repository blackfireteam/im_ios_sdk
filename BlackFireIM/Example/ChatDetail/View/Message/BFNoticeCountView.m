//
//  BFNoticeCountView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/30.
//

#import "BFNoticeCountView.h"
#import "UIView+Frame.h"


@implementation BFNoticeCountView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _countBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_countBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _countBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _countBtn.backgroundColor = [UIColor blueColor];
        [_countBtn addTarget:self action:@selector(countBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_countBtn];
    }
    return self;
}

- (void)increaseCount
{
    [self setHidden:NO];
    NSString *countStr = self.countBtn.titleLabel.text;
    [self.countBtn setTitle:[NSString stringWithFormat:@"%zd",countStr.integerValue+1] forState:UIControlStateNormal];
}

- (void)cleanCount
{
    [self.countBtn setTitle:@"0" forState:UIControlStateNormal];
    [self setHidden:YES];
}

- (void)countBtnDidClick
{
    if ([self.delegate respondsToSelector:@selector(countViewDidTap)]) {
        [self.delegate countViewDidTap];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.countBtn.frame = self.bounds;
    self.layer.cornerRadius = self.height*0.5;
    self.layer.masksToBounds = YES;
}

@end
