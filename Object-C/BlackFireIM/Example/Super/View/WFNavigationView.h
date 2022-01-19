//
//  WFNavigationView.h
//  XiaoMaiQuan
//
//  Created by bennyw on 2017/3/29.
//  Copyright © 2017年 XMQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFNavigationView : UIView

- (instancetype)initWithBackgroundColor:(UIColor *)color
                          leftItemClick:(void(^)(UIButton *leftBtn))leftBlock
                         rightItemClick:(void(^)(UIButton *rightBtn))rightBlock;

@property (nonatomic,strong)UILabel *navTitleL;
@property (nonatomic,strong)UIButton *leftButton;
@property (nonatomic,strong)UIButton *rightButton;
@property (nonatomic,strong)UIView *bottomLine;

@property (nonatomic,strong)UIVisualEffectView *effectView;

@end
