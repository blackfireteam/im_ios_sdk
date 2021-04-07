//
//  BFImageMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFImageMessageCellData.h"
#import "BFHeader.h"

@implementation BFImageMessageCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (MSIMImageElem *)imageElem
{
    return (MSIMImageElem *)self.elem;
}

- (CGSize)contentSize
{
   CGSize size = CGSizeZero;
   size = CGSizeMake(self.imageElem.width, self.imageElem.height);
   if(CGSizeEqualToSize(size, CGSizeZero)){
       return CGSizeMake(200, 200);
   }
   if(size.height > size.width){
       size.width = size.width / size.height * TImageMessageCell_Image_Height_Max;
       size.height = TImageMessageCell_Image_Height_Max;
   } else {
       size.height = size.height / size.width * TImageMessageCell_Image_Width_Max;
       size.width = TImageMessageCell_Image_Width_Max;
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
    return TImageMessageCell_ReuseId;
}

@end
