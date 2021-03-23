//
//  BFFaceCollectionCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFFaceCellData : NSObject

/**
 *  表情名称。
 */
@property(nonatomic,copy) NSString *name;

@end

@interface BFFaceCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *face;

- (void)setData:(BFFaceCellData * _Nullable)data;

@end

NS_ASSUME_NONNULL_END
