//
//  BFWinkMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFWinkMessageCell.h"
#import "BFWinkMessageCellData.h"

@implementation BFWinkMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _animationView = [LOTAnimationView animationNamed:@"wink"];
        _animationView.loopAnimation = YES;
        [self.container addSubview:_animationView];
        _animationView.frame = self.container.bounds;
        _animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_animationView play];
    }
    return self;
}

- (void)fillWithData:(BFWinkMessageCellData *)data
{
    //set data
    [super fillWithData:data];
}

@end
