//
//  BFEditTodInfoController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/8.
//

#import "BFEditTodInfoController.h"
#import "MSIMSDK-UIKit.h"



@interface BFEditTodInfoController ()

@property(nonatomic,strong) UITextView *textView;

@property(nonatomic,strong) UILabel *noticeL;

@end

@implementation BFEditTodInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"编辑群公告";
    
    self.textView.text = self.roomInfo.intro;
    [self.view addSubview:self.textView];
    
    self.textView.editable = self.roomInfo.action_tod;
    if (self.roomInfo.action_tod) {
        [self.textView becomeFirstResponder];
        [self.navView.rightButton setTitle:@"提交" forState:UIControlStateNormal];
    }else {
        [self.view addSubview:self.noticeL];
    }
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(20, NavBar_Height + StatusBar_Height + 20, Screen_Width - 40, 150)];
        _textView.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _textView.font = [UIFont systemFontOfSize:15];
    }
    return _textView;
}

- (UILabel *)noticeL
{
    if (!_noticeL) {
        _noticeL = [[UILabel alloc]initWithFrame:CGRectMake(0, Screen_Height - Bottom_SafeHeight - 100, Screen_Width, 20)];
        _noticeL.text =  @"----  管理员才能编辑和发布聊天室公告  ----";
        _noticeL.font = [UIFont systemFontOfSize:14];
        _noticeL.textColor = [UIColor lightGrayColor];
        _noticeL.textAlignment = NSTextAlignmentCenter;
    }
    return _noticeL;
}

- (void)nav_rightButtonClick
{
    if (self.textView.text.length == 0) return;
    [self.view endEditing:YES];
    WS(weakSelf)
    [[MSIMManager sharedInstance] editChatRoomTOD:self.textView.text toRoom_id:self.roomInfo.room_id successed:^{
        
        [MSHelper showToastSucc:@"发布公告成功"];
        weakSelf.roomInfo.intro = weakSelf.textView.text;
        if (weakSelf.editComplete) {
            weakSelf.editComplete();
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
