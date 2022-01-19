//
//  MSMenuCollectionViewCell.m
//  BlackFireIM
//
//  Created by benny wang on 2022/1/14.
//

#import "MSMenuCollectionViewCell.h"
#import "MSHeader.h"


@implementation MSMenuCellData


@end

@implementation MSMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:TMenuCell_Background_Color dark:TMenuCell_Background_Color_Dark];
    _menu = [[UIImageView alloc] init];
    _menu.backgroundColor = [UIColor clearColor];
    [self addSubview:_menu];
}

- (void)defaultLayout
{
}

- (void)setData:(MSMenuCellData *)data
{
    if(data.isSelected){
        self.backgroundColor = [UIColor d_colorWithColorLight:TMenuCell_Selected_Background_Color dark:TMenuCell_Selected_Background_Color_Dark];
        _menu.image = [UIImage imageNamed:data.selectPath];
    }else {
        self.backgroundColor = [UIColor d_colorWithColorLight:TMenuCell_Background_Color dark:TMenuCell_Background_Color_Dark];
        _menu.image = [UIImage imageNamed:data.normalPath];
    }
    //update layout
    CGSize size = self.frame.size;
    _menu.frame = CGRectMake(TMenuCell_Margin, TMenuCell_Margin, size.width - 2 * TMenuCell_Margin, size.height - 2 * TMenuCell_Margin);
    _menu.contentMode = UIViewContentModeScaleAspectFit;

}

@end
