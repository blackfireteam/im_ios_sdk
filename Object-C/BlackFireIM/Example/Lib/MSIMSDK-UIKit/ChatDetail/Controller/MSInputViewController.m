//
//  MSInputViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "MSInputViewController.h"
#import "MSIMSDK-UIKit.h"
#import "MSFaceUtil.h"

typedef NS_ENUM(NSUInteger, InputStatus) {
    Input_Status_Input,
    Input_Status_Input_Face,
    Input_Status_Input_More,
    Input_Status_Input_Keyboard,
    Input_Status_Input_Talk,
};
@interface MSInputViewController ()<MSInputBarViewDelegate,MSChatMoreViewDelegate,MSFaceViewDelegate,MSMenuViewDelegate>

@property (nonatomic, assign) InputStatus status;

@end

@implementation MSInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    MSLog(@"%@ dealloc",self.class);
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];
    _status = Input_Status_Input;
    _inputBar = [[MSInputBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TTextView_Height)];
    _inputBar.delegate = self;
    [self.view addSubview:_inputBar];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // http://tapd.oa.com/20398462/bugtrace/bugs/view?bug_id=1020398462072883317&url_cache_key=b8dc0f6bee40dMSe0e702ef8cebd5d81
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }else if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }else{
        //[self hideFaceAnimation:NO];
        //[self hideMoreAnimation:NO];
    }
    _status = Input_Status_Input_Keyboard;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:keyboardFrame.size.height + _inputBar.frame.size.height];
    }
}

- (void)hideFaceAnimation
{
    self.faceView.hidden = NO;
    self.faceView.alpha = 1.0;
    self.menuView.hidden = NO;
    self.menuView.alpha = 1.0;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.faceView.alpha = 0.0;
        ws.menuView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.faceView.hidden = YES;
        ws.faceView.alpha = 1.0;
        ws.menuView.hidden = YES;
        ws.menuView.alpha = 1.0;
        [ws.menuView removeFromSuperview];
        [ws.faceView removeFromSuperview];
    }];
}

- (void)showFaceAnimation
{
    [self.view addSubview:self.faceView];
    [self.view addSubview:self.menuView];

    self.faceView.hidden = NO;
    CGRect frame = self.faceView.frame;
    frame.origin.y = Screen_Height;
    self.faceView.frame = frame;

    self.menuView.hidden = NO;
    frame = self.menuView.frame;
    frame.origin.y = self.faceView.frame.origin.y + self.faceView.frame.size.height;
    self.menuView.frame = frame;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.faceView.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.faceView.frame = newFrame;

        newFrame = ws.menuView.frame;
        newFrame.origin.y = ws.faceView.frame.origin.y + ws.faceView.frame.size.height;
        ws.menuView.frame = newFrame;
    } completion:nil];
}

- (void)hideMoreAnimation
{
    self.moreView.hidden = NO;
    self.moreView.alpha = 1.0;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.moreView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.moreView.hidden = YES;
        ws.moreView.alpha = 1.0;
        [ws.moreView removeFromSuperview];
    }];
}

- (void)showMoreAnimation
{
    [self.view addSubview:self.moreView];

    self.moreView.hidden = NO;
    CGRect frame = self.moreView.frame;
    frame.origin.y = Screen_Height;
    self.moreView.frame = frame;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.moreView.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.moreView.frame = newFrame;
    } completion:nil];
}

#pragma mark MSInputBarViewDelegate
- (void)inputBarDidTouchVoice:(MSInputBarView *)textView
{
    if(_status == Input_Status_Input_Talk){
        return;
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self hideFaceAnimation];
    [self hideMoreAnimation];
    _status = Input_Status_Input_Talk;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:TTextView_Height + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchMore:(MSInputBarView *)textView
{
    if(_status == Input_Status_Input_More){
        return;
    }
    if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self showMoreAnimation];
    _status = Input_Status_Input_More;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + self.moreView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchFace:(MSInputBarView *)textView
{
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self showFaceAnimation];
    _status = Input_Status_Input_Face;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + self.faceView.frame.size.height + self.menuView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchKeyboard:(MSInputBarView *)textView
{
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    if (_status == Input_Status_Input_Face) {
        [self hideFaceAnimation];
    }
    _status = Input_Status_Input_Keyboard;
    [_inputBar.inputTextView becomeFirstResponder];
}

- (void)inputBar:(MSInputBarView *)textView didChangeInputHeight:(CGFloat)offset
{
    if(_status == Input_Status_Input_Face){
        [self showFaceAnimation];
    }
    else if(_status == Input_Status_Input_More){
        [self showMoreAnimation];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:self.view.frame.size.height + offset];
    }
}

- (void)inputBar:(MSInputBarView *)textView didSendText:(NSString *)text
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendTextMessage:)]){
        [_delegate inputController:self didSendTextMessage:text];
    }
}

- (void)inputBar:(MSInputBarView *)textView didSendVoice:(NSString *)path
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendVoiceMessage:)]){
        [_delegate inputController:self didSendVoiceMessage:path];
    }
}

- (void)inputBarDidInputAt:(MSInputBarView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerDidInputAt:)]) {
        [_delegate inputControllerDidInputAt:self];
    }
}

- (void)inputBar:(MSInputBarView *)textView didDeleteAt:(NSString *)atText
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didDeleteAt:)]) {
        [_delegate inputController:self didDeleteAt:atText];
    }
}

- (void)inputBarContentDidChanged:(MSInputBarView *_Nonnull)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:contentDidChanged:)]) {
        [_delegate inputController:self contentDidChanged:textView.inputTextView.text];
    }
}

- (void)reset
{
    if(_status == Input_Status_Input){
        return;
    }
    else if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    else if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    _status = Input_Status_Input;
    [_inputBar.inputTextView resignFirstResponder];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + Bottom_SafeHeight];
    }
}

- (MSChatMoreView *)moreView
{
    if(!_moreView){
        _moreView = [[MSChatMoreView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.frame.size.width, 0)];
        _moreView.delegate = self;
        MSInputMoreCellData *cameraData = [[MSInputMoreCellData alloc]initWithType:MSIM_MORE_PHOTO];
        cameraData.title = TUILocalizableString(TUIKitMorePhoto);
        cameraData.image = [UIImage bf_imageNamed:@"more_picture"];
        
        MSInputMoreCellData *photoData = [[MSInputMoreCellData alloc]initWithType:MSIM_MORE_VIDEO];
        photoData.title = TUILocalizableString(TUIKitMoreCamera);
        photoData.image = [UIImage bf_imageNamed:@"more_camera"];
        
//        MSInputMoreCellData *voiceData = [[MSInputMoreCellData alloc]initWithType:MSIM_MORE_VOICE_CALL];
//        voiceData.title = TUILocalizableString(TUIKitMoreVoiceCall);
//        voiceData.image = [UIImage bf_imageNamed:@"more_voice_call"];
//
//        MSInputMoreCellData *videoData = [[MSInputMoreCellData alloc]initWithType:MSIM_MORE_VIDEO_CALL];
//        videoData.title = TUILocalizableString(TUIKitMoreVideoCall);
//        videoData.image = [UIImage bf_imageNamed:@"more_video_call"];
//
        [_moreView setData:@[cameraData,photoData]];
    }
    return _moreView;
}

- (MSFaceView *)faceView
{
    if(!_faceView){
        _faceView = [[MSFaceView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.frame.size.width, 180)];
        _faceView.delegate = self;
        [_faceView setData:[MSFaceUtil defaultConfig].defaultFace];
    }
    return _faceView;
}

- (MSMenuView *)menuView
{
    if(!_menuView){
        _menuView = [[MSMenuView alloc] initWithFrame:CGRectMake(0, self.faceView.frame.origin.y + self.faceView.frame.size.height, self.view.frame.size.width, 40)];
        _menuView.delegate = self;
    }
    return _menuView;
}

#pragma mark - more view delegate
- (void)moreView:(MSChatMoreView *)moreView didSelectMoreCell:(MSInputMoreCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSelectMoreCell:)]){
        [_delegate inputController:self didSelectMoreCell:cell];
    }
}

#pragma mark - MSFaceViewDelegate

- (void)faceView:(MSFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index
{
//    [self.menuView scrollToMenuIndex:index];
}

- (void)faceViewDidBackDelete:(MSFaceView *)faceView
{
    [_inputBar backDelete];
}

- (void)faceView:(MSFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFFaceGroup *group = [MSFaceUtil defaultConfig].defaultFace[indexPath.section];
    BFFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        NSString *faceName = [face.name substringFromIndex:@"emoji/".length];
        [_inputBar addEmoji:faceName];
    }else{
        //直接发送
        // to do
    }
}

#pragma mark - MSMenuViewDelegate

- (void)menuViewDidSendMessage:(MSMenuView *)menuView
{
    NSString *text = [_inputBar getInput];
    if([text isEqualToString:@""]){
        return;
    }
    [_inputBar clearInput];
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendTextMessage:)]){
        [_delegate inputController:self didSendTextMessage:text];
    }
}

@end
