//
//  MSVoiceCallView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/7/23.
//

#import "MSVoiceCallView.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <SDWebImage.h>


@interface MSVoiceCallView()


@end
@implementation MSVoiceCallView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgIcon = [[UIImageView alloc]initWithFrame:UIScreen.mainScreen.bounds];
        self.bgIcon.contentMode = UIViewContentModeScaleAspectFill;
        self.bgIcon.clipsToBounds = YES;
        self.bgIcon.userInteractionEnabled = YES;
        [self addSubview:self.bgIcon];
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
        effectView.frame = self.bgIcon.bounds;
        [self.bgIcon addSubview:effectView];
        
        self.avatarIcon = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_Width*0.5-60, Screen_Height*0.5-100-60, 120, 120)];
        self.avatarIcon.layer.cornerRadius = 4;
        self.avatarIcon.layer.masksToBounds = YES;
        self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgIcon addSubview:self.avatarIcon];
        
        self.durationL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-50, self.avatarIcon.y-50, 100, 20)];
        self.durationL.textColor = [UIColor whiteColor];
        self.durationL.font = [UIFont systemFontOfSize:16];
        self.durationL.textAlignment = NSTextAlignmentCenter;
        [self.bgIcon addSubview:self.durationL];
        
        self.nickNamekL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-50, self.avatarIcon.maxY+15, 100, 35)];
        self.nickNamekL.font = [UIFont boldSystemFontOfSize:20];
        self.nickNamekL.textColor = [UIColor whiteColor];
        self.nickNamekL.textAlignment = NSTextAlignmentCenter;
        [self.bgIcon addSubview:self.nickNamekL];
        
        self.noticeL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-100, self.nickNamekL.maxY+20, 200, 20)];
        self.noticeL.font = [UIFont systemFontOfSize:14];
        self.noticeL.textColor = [UIColor whiteColor];
        self.noticeL.textAlignment = NSTextAlignmentCenter;
        [self.bgIcon addSubview:self.noticeL];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelBtn setTitle:TUILocalizableString(Cancel) forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.cancelBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelBtn.frame = CGRectMake(Screen_Width*0.5-42, Screen_Height-Bottom_SafeHeight-30-114, 84, 114);
        [self.bgIcon addSubview:self.cancelBtn];
        [self.cancelBtn verticalImageAndTitle:15];
        
        self.hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.hangupBtn setTitle:TUILocalizableString(TUIKitCallCancel) forState:UIControlStateNormal];
        [self.hangupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.hangupBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.hangupBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [self.hangupBtn addTarget:self action:@selector(hangupBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.hangupBtn.frame = CGRectMake(Screen_Width*0.5-42, Screen_Height-Bottom_SafeHeight-30-114, 84, 114);
        [self.bgIcon addSubview:self.hangupBtn];
        [self.hangupBtn verticalImageAndTitle:15];
        
        self.micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.micBtn setTitle:TUILocalizableString(TUIKitCallTurningOffMute) forState:UIControlStateNormal];
        [self.micBtn setTitle:TUILocalizableString(TUIKitCallTurningOnMute) forState:UIControlStateSelected];
        [self.micBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.micBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.micBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_mute")] forState:UIControlStateNormal];
        [self.micBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_mute_on")] forState:UIControlStateSelected];
        [self.micBtn addTarget:self action:@selector(mickBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.micBtn.frame = CGRectMake(self.cancelBtn.x-25-self.cancelBtn.width, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self.bgIcon addSubview:self.micBtn];
        [self.micBtn verticalImageAndTitle:15];
        
        self.handFreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.handFreeBtn setTitle:TUILocalizableString(TUIKitCallUsingHeadphone) forState:UIControlStateNormal];
        [self.handFreeBtn setTitle:TUILocalizableString(TUIKitCallUsingSpeaker) forState:UIControlStateSelected];
        [self.handFreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.handFreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.handFreeBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_handsfree")] forState:UIControlStateNormal];
        [self.handFreeBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_handsfree_on")] forState:UIControlStateSelected];
        [self.handFreeBtn addTarget:self action:@selector(handFreeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.handFreeBtn.frame = CGRectMake(self.cancelBtn.maxX+25, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self.bgIcon addSubview:self.handFreeBtn];
        [self.handFreeBtn verticalImageAndTitle:15];
        
        self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rejectBtn setTitle:TUILocalizableString(TUIKitCallReject) forState:UIControlStateNormal];
        [self.rejectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rejectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.rejectBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
        [self.rejectBtn addTarget:self action:@selector(rejectBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.rejectBtn.frame = CGRectMake(Screen_Width*0.5-self.cancelBtn.width-30, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self.bgIcon addSubview:self.rejectBtn];
        [self.rejectBtn verticalImageAndTitle:15];

        self.acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.acceptBtn setTitle:TUILocalizableString(TUIKitCallAccept) forState:UIControlStateNormal];
        [self.acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.acceptBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.acceptBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_dialing")] forState:UIControlStateNormal];
        [self.acceptBtn addTarget:self action:@selector(acceptBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        self.acceptBtn.frame = CGRectMake(Screen_Width*0.5+30, self.rejectBtn.y, self.cancelBtn.width, self.cancelBtn.height);
        [self.bgIcon addSubview:self.acceptBtn];
        [self.acceptBtn verticalImageAndTitle:15];
    }
    return self;
}

- (void)initDataWithSponsor:(BOOL)isMe partner_id:(NSString *)partner_id
{
    [[MSProfileProvider provider] providerProfile:partner_id complete:^(MSProfileInfo * _Nullable profile) {
        if (profile) {
            [self.bgIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
            [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
            self.nickNamekL.text = profile.nick_name;
        }
    }];
    self.noticeL.text = isMe ? TUILocalizableString(TUIKitCallWaitingForAccept) : TUILocalizableString(TUIKitCallInviteYouVoiceCall);
    self.cancelBtn.hidden = !isMe;
    self.micBtn.hidden = !isMe;
    self.micBtn.selected = YES;
    self.handFreeBtn.hidden = !isMe;
    self.handFreeBtn.selected = NO;
    self.rejectBtn.hidden = isMe;
    self.acceptBtn.hidden = isMe;
    self.durationL.hidden = YES;
    self.hangupBtn.hidden = YES;
}

#pragma mark - btn event

- (void)cancelBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(voice_cancelBtnDidClick)]) {
        [self.delegate voice_cancelBtnDidClick];
    }
}

- (void)mickBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(voice_mickBtnDidClick)]) {
        [self.delegate voice_mickBtnDidClick];
    }
}

- (void)handFreeBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(voice_handFreeBtnDidClick)]) {
        [self.delegate voice_handFreeBtnDidClick];
    }
}

- (void)rejectBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(voice_rejectBtnDidClick)]) {
        [self.delegate voice_rejectBtnDidClick];
    }
}

- (void)acceptBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(voice_acceptBtnDidClick)]) {
        [self.delegate voice_acceptBtnDidClick];
    }
}

- (void)hangupBtnDidClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(voice_hangupBtnDidClick)]) {
        [self.delegate voice_hangupBtnDidClick];
    }
}

@end
