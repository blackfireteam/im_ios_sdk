//
//  BFSparkCardCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFSparkCardCell.h"
#import <MSIMSDK/MSIMSDK.h>
#import <SDWebImage.h>
#import "MSIMSDK-UIKit.h"


@interface BFSparkCardCell()

@property(nonatomic,strong) MSProfileInfo *user;

@end
@implementation BFSparkCardCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        self.title = [[UILabel alloc]init];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont boldSystemFontOfSize:25.0f];
        [self.imageView addSubview:self.title];
        
        self.genderIcon = [[UIImageView alloc]init];
        [self.imageView addSubview:self.genderIcon];
        
        self.departmentL = [[UILabel alloc]init];
        self.departmentL.textColor = TText_Color;
        self.departmentL.font = [UIFont systemFontOfSize:12];
        self.departmentL.backgroundColor = [TCell_separatorColor colorWithAlphaComponent:0.5];
        self.departmentL.textAlignment = NSTextAlignmentCenter;
        self.departmentL.layer.cornerRadius = 4;
        self.departmentL.clipsToBounds = YES;
        [self.imageView addSubview:self.departmentL];
        
        self.workplaceL = [[UILabel alloc]init];
        self.workplaceL.textColor = TText_Color;
        self.workplaceL.font = [UIFont systemFontOfSize:12];
        self.workplaceL.backgroundColor = [TCell_separatorColor colorWithAlphaComponent:0.5];
        self.workplaceL.textAlignment = NSTextAlignmentCenter;
        self.workplaceL.layer.cornerRadius = 4;
        self.workplaceL.clipsToBounds = YES;
        [self.imageView addSubview:self.workplaceL];
        
        self.dislike = [[UIImageView alloc]init];
        self.dislike.image = [UIImage imageNamed:@"finder_dislike_btn"];
        self.dislike.alpha = 0.0f;
        [self.imageView addSubview:self.dislike];
        
        self.like = [[UIImageView alloc]init];
        self.like.image = [UIImage imageNamed:@"finder_like_btn"];
        self.like.alpha = 0.0f;
        [self.imageView addSubview:self.like];

        self.winkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.winkBtn setImage:[UIImage imageNamed:@"spark_wink"] forState:UIControlStateNormal];
        [self.winkBtn setImage:[UIImage imageNamed:@"spark_wink_sel"] forState:UIControlStateSelected];
        [self.winkBtn setImage:[UIImage imageNamed:@"spark_wink_sel"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.winkBtn addTarget:self action:@selector(winkBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.winkBtn];
        
        self.chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.chatBtn setImage:[UIImage imageNamed:@"spark_chat"] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(chatBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.chatBtn];
        
        self.layer.cornerRadius = 10;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)configItem:(MSProfileInfo *)info
{
    _user = info;
    NSDictionary *dic = [info.custom el_convertToDictionary];
    NSString *depart = dic[@"department"];
    NSString *pic = dic[@"pic"];
    NSString *place = dic[@"workplace"];
    self.title.text = info.nick_name;
    self.genderIcon.image = info.gender == 1 ? [UIImage bf_imageNamed:@"male"] : [UIImage bf_imageNamed:@"female"];
    self.departmentL.text = [NSString stringWithFormat:@"部门：%@",depart];
    self.workplaceL.text = [NSString stringWithFormat:@"所在地：%@",place];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:XMNoNilString(pic)] placeholderImage:[UIImage imageNamed:@"loadinghead"]];
    self.winkBtn.selected = NO;
}

- (void)winkBtnDidClick
{
    if ([self.delegate respondsToSelector:@selector(winkBtnDidClick:)]) {
        [self.delegate winkBtnDidClick:self];
    }
    [UIDevice impactFeedback];
}

- (void)chatBtnDidClick
{
    if ([self.delegate respondsToSelector:@selector(chatBtnDidClick:)]) {
        [self.delegate chatBtnDidClick:self];
    }
    [UIDevice impactFeedback];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.like.frame = CGRectMake(16, 16, 75, 75);
    self.dislike.frame = CGRectMake(self.frame.size.width - 21 - 75, 16, 75, 75);
    self.winkBtn.frame = CGRectMake(20, self.imageView.height - 50 - 30, 50, 50);
    self.chatBtn.frame = CGRectMake(self.winkBtn.maxX+15, self.winkBtn.y, self.winkBtn.width, self.winkBtn.height);
    CGSize placeSize = [self.workplaceL.text textSizeIn:CGSizeMake(200, 20) font:self.workplaceL.font];
    self.workplaceL.frame = CGRectMake(self.winkBtn.x, self.winkBtn.y - 15 - 25, placeSize.width + 20, 25);
   
    CGSize departSize = [self.departmentL.text textSizeIn:CGSizeMake(200, 20) font:self.departmentL.font];
    self.departmentL.frame =  CGRectMake(self.workplaceL.x, self.workplaceL.y - self.workplaceL.height - 10, departSize.width + 20, self.workplaceL.height);
    
    CGSize titleSize = [self.title.text textSizeIn:CGSizeMake(Screen_Width - 80, 30) font:self.title.font];
    self.title.frame = CGRectMake(self.winkBtn.x,self.departmentL.y - 15 - 30, titleSize.width, 30);
    self.genderIcon.frame = CGRectMake(self.title.maxX + 10, self.title.centerY - 10, 20, 20);
}

@end
