//
//  BFBlackListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFBlackListController.h"

@interface BFBlackListController ()

@end

@implementation BFBlackListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"黑名单";
    [self showEmptyViewInView:self.view];
}

- (NSString *)placeHolderOfImage
{
    return @"content_empty";
}

@end
