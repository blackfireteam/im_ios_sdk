//
//  BFInputMoreCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 消息发送状态*/
typedef NS_ENUM(NSInteger ,BFIMMoreType){
    
    BFIM_MORE_CAMERA = 0, //拍照
    
    BFIM_MORE_PHOTO = 1,//相册
    
    BFIM_MORE_LOCATION = 2,//位置
};

@interface BFInputMoreCellData: NSObject

@property(nonatomic,assign) BFIMMoreType tye;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *title;

- (instancetype)initWithType:(BFIMMoreType)type;

@end

@interface BFInputMoreCell : UICollectionViewCell

/**
 *  更多单元对应的图标，从 TUIInputMoreCellData 的 iamge 中获取。
 *  各个单元的图标有所不同，用于形象表示该单元所对应的功能。
 */
@property (nonatomic, strong) UIImageView *image;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) BFInputMoreCellData *data;

- (void)fillWithData:(BFInputMoreCellData *)data;

+ (CGSize)getSize;

@end

NS_ASSUME_NONNULL_END
