//
//  BFFeedbackController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/27.
//

#import "BFFeedbackController.h"
#import "MSHeader.h"


@interface BFFeedbackController ()

@property(nonatomic,strong) UITextView *textView;

@end

@implementation BFFeedbackController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"意见反馈";
    self.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TInput_Background_Color_Dark];
    [self.navView.rightButton setTitle:@"提交" forState:UIControlStateNormal];
    self.textView.frame = CGRectMake(15, NavBar_Height + StatusBar_Height + 20, Screen_Width - 30, 300);
    [self.view addSubview:self.textView];
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];
    }
    return _textView;
}

- (void)nav_rightButtonClick
{
    [MSHelper showToastSucc:@"提交成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
