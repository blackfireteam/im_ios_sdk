//
//  BFInputMoreCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import "MSInputMoreCell.h"


@implementation MSInputMoreCellData

- (instancetype)initWithType:(MSIMMoreType)type
{
    if (self = [super init]) {
        _tye = type;
    }
    return self;
}

@end

@implementation MSInputMoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:14]];
    [_title setTextColor:[UIColor grayColor]];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)fillWithData:(MSInputMoreCellData *)data
{
    //set data
    _data = data;
    _image.image = data.image;
    [_title setText:data.title];
    //update layout
    CGSize menuSize = CGSizeMake(65, 65);
    _image.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    _title.frame = CGRectMake(0, _image.frame.origin.y + _image.frame.size.height + 5, _image.frame.size.width, 20);
}

+ (CGSize)getSize
{
    CGSize menuSize = CGSizeMake(65, 65);
    return CGSizeMake(menuSize.width, menuSize.height + 25);
}

@end
