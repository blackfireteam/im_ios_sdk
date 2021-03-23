//
//  BFInputMoreCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import "BFInputMoreCell.h"


@implementation BFInputMoreCellData

- (instancetype)initWithType:(BFIMMoreType)type
{
    if (self = [super init]) {
        _tye = type;
    }
    return self;
}

@end

@implementation BFInputMoreCell

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

- (void)fillWithData:(BFInputMoreCellData *)data
{
    //set data
    _data = data;
    _image.image = data.image;
    [_title setText:data.title];
    //update layout
    CGSize menuSize = CGSizeMake(70, 70);
    _image.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    _title.frame = CGRectMake(0, _image.frame.origin.y + _image.frame.size.height, _image.frame.size.width, 20);
}

+ (CGSize)getSize
{
    CGSize menuSize = CGSizeMake(70, 70);
    return CGSizeMake(menuSize.width, menuSize.height + 20);
}

@end
