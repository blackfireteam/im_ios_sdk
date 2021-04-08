//
//  BFVideoMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/2.
//

#import "BFVideoMessageCellData.h"
#import "BFHeader.h"


@implementation BFVideoMessageCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (MSIMVideoElem *)videoElem
{
    return (MSIMVideoElem *)self.elem;
}

- (CGSize)contentSize
{
   CGSize size = CGSizeZero;
   size = CGSizeMake(self.videoElem.width, self.videoElem.height);
   if(CGSizeEqualToSize(size, CGSizeZero)){
       return CGSizeMake(200, 200);
   }
   if(size.height > size.width){
       size.width = size.width / size.height * TVideoMessageCell_Image_Height_Max;
       size.height = TVideoMessageCell_Image_Height_Max;
   } else {
       size.height = size.height / size.width * TVideoMessageCell_Image_Width_Max;
       size.width = TVideoMessageCell_Image_Width_Max;
   }
   return size;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    CGFloat height = 0;
    if (self.showName) {
        height += 25;
    }
    CGSize containerSize = [self contentSize];
    height += containerSize.height;
    if (self.direction == MsgDirectionIncoming) {
        height += 15;
    }
    height += 5 + 5;
    return height;
}

- (NSString *)reuseId
{
    return TVideoMessageCell_ReuseId;
}

@end
