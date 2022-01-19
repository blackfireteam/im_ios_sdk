//
//  BFSelectDepartView.m
//  BlackFireIM
//
//  Created by benny wang on 2022/1/5.
//

#import "BFSelectorView.h"
#import "MSHeader.h"

@interface BFSelectorView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,assign) NSInteger selectType;

@property(nonatomic,strong) NSArray *datasource;

@property(nonatomic,strong) UIPickerView *picker;

@property(nonatomic,copy) void (^submitAction)(NSString *text);

@property(nonatomic,copy) void (^cancelAction)(void);

@property(nonatomic,copy) NSString *selectText;

@end
@implementation BFSelectorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 12;
        self.backgroundColor = [UIColor d_colorWithColorLight:TPage_Color dark:TPage_Color_Dark];
        
        self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, frame.size.width, 230)];
        self.picker.delegate = self;
        self.picker.dataSource = self;
        [self addSubview:self.picker];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.frame = CGRectMake(10, 5, 60, 30);
        [self addSubview:cancelBtn];
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
        submitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [submitBtn addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
        submitBtn.frame = CGRectMake(frame.size.width - 10 - 60, 5, 60, 30);
        [self addSubview:submitBtn];
    }
    return self;
}

- (void)cancelClick:(UIButton *)sender
{
    if (self.cancelAction) self.cancelAction();
    [UIView animateWithDuration:0.25 animations:^{
        self.y = Screen_Height;
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
    }];
}

- (void)submitClick:(UIButton *)sender
{
    if (self.submitAction) self.submitAction(self.selectText);
    [UIView animateWithDuration:0.25 animations:^{
        self.y = Screen_Height;
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
    }];
}

- (void)backBtnClick
{
    if (self.cancelAction) self.cancelAction();
    [UIView animateWithDuration:0.25 animations:^{
        self.y = Screen_Height;
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
    }];
}

+ (void)showSelectView:(NSInteger)type
          submitAction:(nullable void(^)(NSString *text))submitAction
                cancel:(nullable void(^)(void))cancelAction
{
    CGFloat viewH = 230 + 40 + Bottom_SafeHeight;
    BFSelectorView *departView = [[BFSelectorView alloc]initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, viewH)];
    departView.submitAction = submitAction;
    departView.cancelAction = cancelAction;
    departView.selectType = type;
    if (type == 0) {
        departView.datasource = @[@"SALE&MARKETING",@"HR&ADMIN",@"PRODUCT&DESIGN",@"ENGINEERING",@"CS&QA",@"FINANCE",@"NEW_PRODUCTS",@"OTHERS"];
        departView.selectText = departView.datasource.firstObject;
    }else if(type == 1) {
        departView.datasource = @[@"HX-27F",@"HX-25F",@"HX-22F",@"HX-21F",@"Nanchong",@"Mianyang",@"West",@"Leshan",@"iUniverse",@"Indian sales office",@"Indian development office"];
        departView.selectText = departView.datasource.firstObject;
    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:departView action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    [backBtn addSubview:departView];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:backBtn];
    [UIView animateWithDuration:0.25 animations:^{
        departView.y = Screen_Height - viewH;
    }];
}

#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.datasource.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.datasource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectText = self.datasource[row];
}

@end
