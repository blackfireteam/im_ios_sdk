//
//  MSFaceCollectionCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFFaceCellData : NSObject

@property(nonatomic,copy) NSString *e_id;

@property(nonatomic,copy) NSString *name;

@property(nonatomic,copy) NSString *facePath;
@end

@interface MSFaceCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *face;

- (void)setData:(BFFaceCellData * _Nullable)data;

@end

NS_ASSUME_NONNULL_END
