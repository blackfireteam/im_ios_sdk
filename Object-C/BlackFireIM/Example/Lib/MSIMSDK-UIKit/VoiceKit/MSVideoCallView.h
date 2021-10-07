//
//  MSVideoCallView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MSVideoCallViewDelegate<NSObject>

- (void)video_remoteViewDidTap;

- (void)video_cancelBtnDidClick;

- (void)video_cameraBtnDidClick;

- (void)video_rejectBtnDidClick;

- (void)video_acceptBtnDidClick;

- (void)video_hangupBtnDidClick;

@end
@interface MSVideoCallView : UIView

@property(nonatomic,strong) UIView *localView;

@property(nonatomic,strong) UIView *remoteView;

@property(nonatomic,strong) UIImageView *avatarIcon;

@property(nonatomic,strong) UILabel *nickNamekL;

@property(nonatomic,strong) UILabel *noticeL;

@property(nonatomic,strong) UIButton *cancelBtn;

@property(nonatomic,strong) UIButton *hangupBtn;

@property(nonatomic,strong) UIButton *cameraBtn;

@property(nonatomic,strong) UIButton *rejectBtn;

@property(nonatomic,strong) UIButton *acceptBtn;

@property(nonatomic,strong) UILabel *durationL;

@property(nonatomic,weak) id<MSVideoCallViewDelegate> delegate;

- (void)initDataWithSponsor:(BOOL)isMe partner_id:(NSString *)partner_id;

@end

NS_ASSUME_NONNULL_END
