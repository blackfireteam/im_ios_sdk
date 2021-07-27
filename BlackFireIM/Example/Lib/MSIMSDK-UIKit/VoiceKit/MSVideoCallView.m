//
//  MSVideoCallView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/7/23.
//

#import "MSVideoCallView.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <SDWebImage.h>


@implementation MSVideoCallView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.localView = [[UIView alloc]initWithFrame:UIScreen.mainScreen.bounds];
        [self addSubview:self.localView];
        
        self.remoteView = [[UIView alloc]initWithFrame:CGRectMake(Screen_Width-20-90, StatusBar_Height + NavBar_Height, 90, 160)];
        self.remoteView.layer.cornerRadius = 6;
        self.remoteView.clipsToBounds = YES;
        [self addSubview:self.remoteView];
        UITapGestureRecognizer *remoteTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remoteViewTap)];
        [self.remoteView addGestureRecognizer:remoteTap];
        
        self.avatarIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20, StatusBar_Height + NavBar_Height, 70, 70)];
        self.avatarIcon.layer.cornerRadius = 4;
        self.avatarIcon.layer.masksToBounds = YES;
        self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.avatarIcon];
        
        self.durationL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-50, StatusBar_Height + NavBar_Height, 100, 20)];
        self.durationL.textColor = [UIColor whiteColor];
        self.durationL.font = [UIFont systemFontOfSize:16];
        self.durationL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.durationL];
        
        self.nickNamekL = [[UILabel alloc]initWithFrame:CGRectMake(self.avatarIcon.maxX+15, self.avatarIcon.y, 200, 35)];
        self.nickNamekL.font = [UIFont boldSystemFontOfSize:20];
        self.nickNamekL.textColor = [UIColor whiteColor];
        [self addSubview:self.nickNamekL];
        
        self.noticeL = [[UILabel alloc]initWithFrame:CGRectMake(self.nickNamekL.x, self.nickNamekL.maxY+12, 200, 20)];
        self.noticeL.font = [UIFont systemFontOfSize:14];
        self.noticeL.textColor = [UIColor whiteColor];
        [self addSubview:self.noticeL];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelBtn setTitle:TUILocalizableString(Cancel) forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.cancelBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelBtn.frame = CGRectMake(Screen_Width*0.5-42, Screen_Height-Bottom_SafeHeight-30-114, 84, 114);
        [self addSubview:self.cancelBtn];
        [self.cancelBtn verticalImageAndTitle:15];
        
        self.hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.hangupBtn setTitle:TUILocalizableString(TUIKitCallCancel) forState:UIControlStateNormal];
        [self.hangupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.hangupBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.hangupBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [self.hangupBtn addTarget:self action:@selector(hangupBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.hangupBtn.frame = CGRectMake(Screen_Width*0.5-self.cancelBtn.width-30, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self addSubview:self.hangupBtn];
        [self.hangupBtn verticalImageAndTitle:15];
        
        self.cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cameraBtn setTitle:TUILocalizableString(TUIKitCallCameraSwitch) forState:UIControlStateNormal];
        [self.cameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.cameraBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.cameraBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_camera")] forState:UIControlStateNormal];
        [self.cameraBtn addTarget:self action:@selector(cameraBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cameraBtn.frame = CGRectMake(Screen_Width*0.5+30, self.hangupBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self addSubview:self.cameraBtn];
        [self.cameraBtn verticalImageAndTitle:15];
        
        self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rejectBtn setTitle:TUILocalizableString(TUIKitCallReject) forState:UIControlStateNormal];
        [self.rejectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rejectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.rejectBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [self.rejectBtn addTarget:self action:@selector(rejectBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.rejectBtn.frame = CGRectMake(Screen_Width*0.5-self.cancelBtn.width-30, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self addSubview:self.rejectBtn];
        [self.rejectBtn verticalImageAndTitle:15];

        self.acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.acceptBtn setTitle:TUILocalizableString(TUIKitCallAccept) forState:UIControlStateNormal];
        [self.acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.acceptBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.acceptBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_dialing")] forState:UIControlStateNormal];
        [self.acceptBtn addTarget:self action:@selector(acceptBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.acceptBtn.frame = CGRectMake(Screen_Width*0.5+30, self.rejectBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self addSubview:self.acceptBtn];
        [self.acceptBtn verticalImageAndTitle:15];
    }
    return self;
}

- (void)initDataWithSponsor:(BOOL)isMe partner_id:(NSString *)partner_id
{
    [[MSProfileProvider provider] providerProfile:partner_id complete:^(MSProfileInfo * _Nullable profile) {
        if (profile) {
            [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
            self.nickNamekL.text = profile.nick_name;
        }
    }];
    self.noticeL.text = isMe ? TUILocalizableString(TUIKitCallWaitingForAccept) : TUILocalizableString(TUIKitCallInviteYouVideoCall);
    self.cancelBtn.hidden = !isMe;
    self.cameraBtn.hidden = YES;
    self.rejectBtn.hidden = isMe;
    self.acceptBtn.hidden = isMe;
    self.durationL.hidden = YES;
    self.hangupBtn.hidden = YES;
    self.remoteView.hidden = YES;
}

#pragma mark - btn event

- (void)remoteViewTap
{
    if ([self.delegate respondsToSelector:@selector(video_remoteViewDidTap)]) {
        [self.delegate video_remoteViewDidTap];
    }
}

- (void)cancelBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(video_cancelBtnDidClick)]) {
        [self.delegate video_cancelBtnDidClick];
    }
}

- (void)cameraBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(video_cameraBtnDidClick)]) {
        [self.delegate video_cameraBtnDidClick];
    }
}

- (void)rejectBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(video_rejectBtnDidClick)]) {
        [self.delegate video_rejectBtnDidClick];
    }
}

- (void)acceptBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(video_acceptBtnDidClick)]) {
        [self.delegate video_acceptBtnDidClick];
    }
}

- (void)hangupBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(video_hangupBtnDidClick)]) {
        [self.delegate video_hangupBtnDidClick];
    }
}

@end
