//
//  MSLocationListCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/29.
//

#import "MSLocationListCell.h"
#import "MSIMSDK-UIKit.h"


@interface MSLocationListCell()



@end
@implementation MSLocationListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        [self.contentView addSubview:self.titleL];
        [self.contentView addSubview:self.addressL];
        [self.contentView addSubview:self.checkIcon];
        
    }
    return self;
}

- (void)configCell:(MSLocationInfo *)info
{
    self.titleL.text = info.name;
    self.addressL.text = [NSString stringWithFormat:@"%zd m | %@%@",info.distance,XMNoNilString(info.district),XMNoNilString(info.address)];
    self.checkIcon.hidden = !info.isSelect;
}

- (UILabel *)titleL
{
    if (!_titleL) {
        _titleL = [[UILabel alloc]init];
        _titleL.font = [UIFont systemFontOfSize:16];
        _titleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    }
    return _titleL;
}

- (UILabel *)addressL
{
    if (!_addressL) {
        _addressL = [[UILabel alloc]init];
        _addressL.font = [UIFont systemFontOfSize:13];
        _addressL.textColor = [UIColor d_systemGrayColor];
    }
    return _addressL;
}

- (UIImageView *)checkIcon
{
    if (!_checkIcon) {
        _checkIcon = [[UIImageView alloc]init];
        _checkIcon.image = [UIImage imageNamed:TUIKitResource(@"ic_selected")];
    }
    return _checkIcon;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleL.frame = CGRectMake(15, 15, Screen_Width - 30 - 40, 16);
    self.addressL.frame = CGRectMake(15, self.titleL.maxY + 10, self.titleL.width, 13);
    self.checkIcon.frame = CGRectMake(Screen_Width - 15 - 22, self.height * 0.5 - 11, 22, 22);
}

@end
