//
//  MSImageMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSImageMessageCellData.h"
#import "MSIMSDK-UIKit.h"

@implementation MSImageMessageCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (CGSize)contentSize
{
   CGSize size = CGSizeZero;
   size = CGSizeMake(self.message.imageElem.width, self.message.imageElem.height);
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
    if (self.direction == MsgDirectionOutgoing) {
        height += 20;
    }
    height += 5 + 5;
    return height;
}

- (NSString *)reuseId
{
    return TImageMessageCell_ReuseId;
}

@end
