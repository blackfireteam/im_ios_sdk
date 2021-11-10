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

@end

@implementation BFEditTodInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发布群公告";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submit)];
    
    self.textView.text = self.roomInfo.intro;
    [self.view addSubview:self.textView];
    [self.textView becomeFirstResponder];
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

- (void)submit
{
    if (self.textView.text.length == 0) return;
    [self.view endEditing:YES];
    WS(weakSelf)
    [[MSIMManager sharedInstance] editChatRoomTOD:self.textView.text toRoom_id:self.roomInfo.room_id successed:^{
        
        [MSHelper showToastSucc:@"发布公告成功"];
        ///公告发布成功，模拟发一条公告文本消息
        MSIMTextElem *textElem = [[MSIMManager sharedInstance]createTextMessage:[NSString stringWithFormat:@"[Tip of Day]\n%@",weakSelf.textView.text]];
        [[MSIMManager sharedInstance]sendChatRoomMessage:textElem toRoomID:weakSelf.roomInfo.room_id successed:^(NSInteger msg_id) {
            
        } failed:^(NSInteger code, NSString *desc) {
            
        }];
        [self.navigationController popViewControllerAnimated:YES];
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

@end
