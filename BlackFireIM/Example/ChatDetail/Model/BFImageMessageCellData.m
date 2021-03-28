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
        _uploadProgress = 100;
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
    if (self.imageElem.path.length > 0) {
        NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.imageElem.path];
        if ([[NSFileManager defaultManager]fileExistsAtPath:imagePath]) {
            self.thumbImage = [UIImage imageWithContentsOfFile:imagePath];
            size = self.thumbImage.size;
        }
    }
   size = CGSizeMake(self.imageElem.width, self.imageElem.height);
   if(CGSizeEqualToSize(size, CGSizeZero)){
       return size;
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

- (NSString *)reuseId
{
    return TImageMessageCell_ReuseId;
}

@end
