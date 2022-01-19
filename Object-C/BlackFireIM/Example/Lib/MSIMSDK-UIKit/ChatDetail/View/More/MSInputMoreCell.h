//
//  BFInputMoreCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger ,MSIMMoreType){
    
    MSIM_MORE_PHOTO = 0, //照片
    
    MSIM_MORE_VIDEO = 1,//视频
    
    MSIM_MORE_LOCATION = 2,//位置
    
    MSIM_MORE_VOICE_CALL = 3, //语音通话
    
    MSIM_MORE_VIDEO_CALL = 4, //视频通话
    
    MSIM_MORE_SNAP_CHAT = 5, //阅后即焚
};

@interface MSInputMoreCellData: NSObject

@property(nonatomic,assign) MSIMMoreType tye;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *title;

- (instancetype)initWithType:(MSIMMoreType)type;

@end

@interface MSInputMoreCell : UICollectionViewCell

/**
 *  更多单元对应的图标，从 TUIInputMoreCellData 的 iamge 中获取。
 *  各个单元的图标有所不同，用于形象表示该单元所对应的功能。
 */
@property (nonatomic, strong) UIImageView *image;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) MSInputMoreCellData *data;

- (void)fillWithData:(MSInputMoreCellData *)data;

+ (CGSize)getSize;

@end

NS_ASSUME_NONNULL_END
