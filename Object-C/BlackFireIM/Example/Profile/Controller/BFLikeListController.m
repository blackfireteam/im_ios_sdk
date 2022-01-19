//
//  BFLikeListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/24.
//

#import "BFLikeListController.h"

@interface BFLikeListController ()

@end

@implementation BFLikeListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.type == 0) {
        self.navView.navTitleL.text = @"我喜欢的";
    }else if (self.type == 1) {
        self.navView.navTitleL.text = @"喜欢我的";
    }else {
        self.navView.navTitleL.text = @"最近来访";
    }
    [self showEmptyViewInView:self.view];
}

- (NSString *)placeHolderOfImage
{
    return @"network_empty";
}

@end
