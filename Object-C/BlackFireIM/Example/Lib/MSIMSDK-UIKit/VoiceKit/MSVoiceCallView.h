//
//  MSVoiceCallView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol MSVoiceCallViewDelegate<NSObject>


- (void)voice_cancelBtnDidClick;

- (void)voice_mickBtnDidClick;

- (void)voice_handFreeBtnDidClick;

- (void)voice_rejectBtnDidClick;

- (void)voice_acceptBtnDidClick;

- (void)voice_hangupBtnDidClick;

@end
@interface MSVoiceCallView : UIView

@property(nonatomic,strong) UIImageView *bgIcon;

@property(nonatomic,strong) UIImageView *avatarIcon;

@property(nonatomic,strong) UILabel *nickNamekL;

@property(nonatomic,strong) UILabel *noticeL;

@property(nonatomic,strong) UIButton *micBtn;

@property(nonatomic,strong) UIButton *cancelBtn;

@property(nonatomic,strong) UIButton *hangupBtn;

@property(nonatomic,strong) UIButton *handFreeBtn;

@property(nonatomic,strong) UIButton *rejectBtn;

@property(nonatomic,strong) UIButton *acceptBtn;

@property(nonatomic,strong) UILabel *durationL;

@property(nonatomic,weak) id<MSVoiceCallViewDelegate> delegate;

- (void)initDataWithSponsor:(BOOL)isMe partner_id:(NSString *)partner_id;

@end

NS_ASSUME_NONNULL_END
