//
//  BFBaseViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import "BFBaseViewController.h"
#import "UIColor+BFDarkMode.h"


@interface BFBaseViewController ()

@end

@implementation BFBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //修改返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
    self.view.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor blackColor]];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",self.class);
}

@end
