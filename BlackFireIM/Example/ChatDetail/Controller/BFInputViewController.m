//
//  BFInputViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "BFInputViewController.h"
#import "BFHeader.h"
#import "UIColor+BFDarkMode.h"
#import "NSBundle+BFKit.h"
#import "UIImage+BFKit.h"


typedef NS_ENUM(NSUInteger, InputStatus) {
    Input_Status_Input,
    Input_Status_Input_Face,
    Input_Status_Input_More,
    Input_Status_Input_Keyboard,
    Input_Status_Input_Talk,
};
@interface BFInputViewController ()<BFInputBarViewDelegate,BFChatMoreViewDelegate,BFFaceViewDelegate,BFMenuViewDelegate>

@property (nonatomic, assign) InputStatus status;

@property(nonatomic,strong) NSMutableArray *defaultFace;

@end

@implementation BFInputViewController

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

- (void)setupUI
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];
    _status = Input_Status_Input;
    _inputBar = [[BFInputBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TTextView_Height)];
    _inputBar.delegate = self;
    [self.view addSubview:_inputBar];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // http://tapd.oa.com/20398462/bugtrace/bugs/view?bug_id=1020398462072883317&url_cache_key=b8dc0f6bee40dbfe0e702ef8cebd5d81
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

#pragma mark BFInputBarViewDelegate
- (void)inputBarDidTouchVoice:(BFInputBarView *)textView
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

- (void)inputBarDidTouchMore:(BFInputBarView *)textView
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

- (void)inputBarDidTouchFace:(BFInputBarView *)textView
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

- (void)inputBarDidTouchKeyboard:(BFInputBarView *)textView
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

- (void)inputBar:(BFInputBarView *)textView didChangeInputHeight:(CGFloat)offset
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

- (void)inputBar:(BFInputBarView *)textView didSendText:(NSString *)text
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:text];
    }
}

- (void)inputBar:(BFInputBarView *)textView didSendVoice:(NSString *)path
{
}

- (void)inputBarDidInputAt:(BFInputBarView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerDidInputAt:)]) {
        [_delegate inputControllerDidInputAt:self];
    }
}

- (void)inputBar:(BFInputBarView *)textView didDeleteAt:(NSString *)atText
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didDeleteAt:)]) {
        [_delegate inputController:self didDeleteAt:atText];
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

- (BFChatMoreView *)moreView
{
    if(!_moreView){
        _moreView = [[BFChatMoreView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.frame.size.width, 0)];
        _moreView.delegate = self;
        BFInputMoreCellData *cameraData = [[BFInputMoreCellData alloc]initWithType:BFIM_MORE_CAMERA];
        cameraData.title = [NSBundle bf_localizedStringForKey:@"TUIKitMoreCamera"];
        cameraData.image = [UIImage bf_imageNamed:@"more_camera"];
        
        BFInputMoreCellData *photoData = [[BFInputMoreCellData alloc]initWithType:BFIM_MORE_PHOTO];
        photoData.title = [NSBundle bf_localizedStringForKey:@"TUIKitMorePhoto"];
        photoData.image = [UIImage bf_imageNamed:@"more_picture"];
        
        [_moreView setData:@[cameraData,photoData]];
    }
    return _moreView;
}

- (BFFaceView *)faceView
{
    if(!_faceView){
        _faceView = [[BFFaceView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.frame.size.width, 180)];
        _faceView.delegate = self;
        [_faceView setData:self.defaultFace];
    }
    return _faceView;
}

- (NSMutableArray *)defaultFace
{
    if (!_defaultFace) {
        _defaultFace = [NSMutableArray array];
        //emoji group
        NSMutableArray *emojiFaces = [NSMutableArray array];
        NSArray *emojis = [NSArray arrayWithContentsOfFile:TUIKitFace(@"emoji/emoji.plist")];
        for (NSDictionary *dic in emojis) {
            BFFaceCellData *data = [[BFFaceCellData alloc] init];
            NSString *name = [dic objectForKey:@"face_name"];
            data.name = [NSString stringWithFormat:@"emoji/%@",name];
            [emojiFaces addObject:data];
        }
        if(emojiFaces.count != 0){
            BFFaceGroup *emojiGroup = [[BFFaceGroup alloc] init];
            emojiGroup.groupIndex = 0;
            emojiGroup.groupPath = TUIKitFace(@"emoji/");
            emojiGroup.faces = emojiFaces;
            emojiGroup.rowCount = 3;
            emojiGroup.itemCountPerRow = 9;
            emojiGroup.needBackDelete = YES;
            [_defaultFace addObject:emojiGroup];
        }
    }
    return _defaultFace;
}

- (BFMenuView *)menuView
{
    if(!_menuView){
        _menuView = [[BFMenuView alloc] initWithFrame:CGRectMake(0, self.faceView.frame.origin.y + self.faceView.frame.size.height, self.view.frame.size.width, 40)];
        _menuView.delegate = self;
    }
    return _menuView;
}

#pragma mark - more view delegate
- (void)moreView:(BFChatMoreView *)moreView didSelectMoreCell:(BFInputMoreCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSelectMoreCell:)]){
        [_delegate inputController:self didSelectMoreCell:cell];
    }
}

#pragma mark - BFFaceViewDelegate

- (void)faceView:(BFFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index
{
//    [self.menuView scrollToMenuIndex:index];
}

- (void)faceViewDidBackDelete:(BFFaceView *)faceView
{
    [_inputBar backDelete];
}

- (void)faceView:(BFFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BFFaceGroup *group = self.defaultFace[indexPath.section];
    BFFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        NSString *faceName = [face.name substringFromIndex:@"emoji/".length];
        [_inputBar addEmoji:faceName];
    }else{
        //直接发送
        // to do
    }
}

#pragma mark - BFMenuViewDelegate

- (void)menuViewDidSendMessage:(BFMenuView *)menuView
{
    NSString *text = [_inputBar getInput];
    if([text isEqualToString:@""]){
        return;
    }
    [_inputBar clearInput];
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:text];
    }
}

@end
