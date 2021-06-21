//
//  MSFaceCollectionCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "MSFaceCollectionCell.h"
#import "MSHeader.h"


@implementation BFFaceCellData
@end

@implementation MSFaceCollectionCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    _face = [[UIImageView alloc] init];
    _face.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_face];
}

- (void)defaultLayout
{
    CGSize size = self.frame.size;
    _face.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)setData:(BFFaceCellData * _Nullable)data
{
    self.face.image = [UIImage imageNamed:TUIKitFace(data.name)];
    [self defaultLayout];
}


@end
