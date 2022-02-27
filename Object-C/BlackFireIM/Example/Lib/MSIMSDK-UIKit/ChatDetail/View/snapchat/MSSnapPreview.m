//
//  MSSnapPreview.m
//  BlackFireIM
//
//  Created by benny wang on 2022/2/22.
//

#import "MSSnapPreview.h"

@interface MSSnapPreview()

@property(nonatomic,strong) MSIMMessage *message;


@end
@implementation MSSnapPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
        
        self.scrollView = [[UIScrollView alloc]init];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        self.countL = [[UILabel alloc]init];
        self.countL.textColor = [UIColor whiteColor];
        self.countL.backgroundColor = [UIColor redColor];
        self.countL.font = [UIFont systemFontOfSize:16];
        self.countL.textAlignment = NSTextAlignmentCenter;
        self.countL.layer.cornerRadius = 15;
        self.countL.layer.masksToBounds = YES;
        [self addSubview:self.countL];
        
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeBtn setImage:[UIImage imageNamed:TUIKitResource(@"nav_close")] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
    }
    return self;
}

- (void)closeBtnClick
{
    [self dismissWithAnimation:YES];
}

- (void)reloadMessage:(MSIMMessage *)message
{
    _message = message;
    if (message.isSelf == NO) {
        self.countL.hidden = NO;
        NSInteger count = [[MSSnapChatTimerManager defaultManager]startCountDownWithMessage:message];
        self.countL.text = [NSString stringWithFormat:@"%zd",count];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snapCountChanged:) name:SNAPCHAT_COUNTDOWN_CHANGED object:nil];
    }else {
        self.countL.hidden = YES;
    }
}

- (void)snapCountChanged:(NSNotification *)note
{
    NSDictionary *dic = note.object;
    NSString *msg_id = dic[@"msg_id"];
    NSInteger count = [dic[@"count"] integerValue];
    if (self.message.msgID == msg_id.integerValue) {
        self.countL.text = [NSString stringWithFormat:@"%zd",count];
        if (count == 0) {
            [self dismissWithAnimation:YES];
        }
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self bringSubviewToFront:self.closeBtn];
    [self bringSubviewToFront:self.countL];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.closeBtn.frame = CGRectMake(20, StatusBar_Height + 20, NavBar_Height, NavBar_Height);
    self.scrollView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    self.countL.frame = CGRectMake(Screen_Width - 30 - 20, NavBar_Height + StatusBar_Height, 30, 30);
}

- (void)showWithAnimation:(BOOL)animate
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
    if (animate) {
        self.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)dismissWithAnimation:(BOOL)animate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else {
        [self removeFromSuperview];
    }
}

@end
