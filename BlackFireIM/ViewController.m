//
//  ViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "ViewController.h"
#import "NSString+AES.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *hello = @"hi man,fuck";
    NSString *encryStr = [NSString encryptAES:hello key:nil];
    NSLog(@"encryStr = %@",encryStr);
    
    NSString *originStr = [NSString decryptAES:@"cMfbLoIVfAIVW18MG4LaSZVY2i+l9MZMxw+zfxI7r9XTN8djq+ZgK+7p1S0BxFh6UstwELu0odjQhYAcSNP/qgIXW70nUKFt+h+MC0TauPI=" key:nil];
    NSLog(@"解密数据：%@",originStr);
}


@end
