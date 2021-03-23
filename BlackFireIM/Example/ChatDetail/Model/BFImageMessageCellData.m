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

- (CGSize)contentSize
{
   CGSize size = CGSizeZero;
   BOOL isDir = NO;
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.imageElem.path];
   if(![imagePath isEqualToString:@""] &&
      [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDir]){
       if(!isDir){
           size = [UIImage imageWithContentsOfFile:imagePath].size;
       }
   }

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
