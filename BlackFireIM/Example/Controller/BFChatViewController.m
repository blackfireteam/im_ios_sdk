//
//  BFChatViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/17.
//

#import "BFChatViewController.h"
#import "UIColor+BFDarkMode.h"
#import "BFHeader.h"
#import "BFMessageController.h"
#import "BFInputViewController.h"


@interface BFChatViewController ()<BFInputViewControllerDelegate>

@property(nonatomic,strong) BFMessageController *messageController;

@property(nonatomic,strong) BFInputViewController *inputController;

@end

@implementation BFChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.messageController = [[BFMessageController alloc]init];
    self.messageController.view.frame = CGRectMake(0, 0, Screen_Width, Screen_Height-TTextView_Height-Bottom_SafeHeight);
    [self addChildViewController:self.messageController];
    [self.view addSubview:self.messageController.view];
    
    self.inputController = [[BFInputViewController alloc]init];
    self.inputController.accessibilityFrame = CGRectMake(0, Screen_Height-TTextView_Height-Bottom_SafeHeight, Screen_Width, TTextView_Height+Bottom_SafeHeight);
    self.inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.inputController.delegate = self;
    [self addChildViewController:self.inputController];
    [self.view addSubview:self.inputController.view];
    
}

#pragma mark - <BFInputViewControllerDelegate>

- (void)inputController:(BFInputViewController *)inputController didChangeHeight:(CGFloat)height
{
    WS(weakSelf)
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = weakSelf.messageController.view.frame;
        msgFrame.size.height = weakSelf.view.frame.size.height-height;
        weakSelf.messageController.view.frame = msgFrame;
        
        CGRect inputFrame = weakSelf.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        weakSelf.inputController.view.frame = inputFrame;
        [weakSelf.messageController scrollToBottom:NO];
        } completion:^(BOOL finished) {
            
        }];
}

- (void)inputController:(BFInputViewController *)inputController didSendMessage:(NSString *)msg
{
    
}

- (void)inputControllerDidInputAt:(BFInputViewController *)inputController
{
    
}


@end
