//
//  MSMenuCollectionViewCell.h
//  BlackFireIM
//
//  Created by benny wang on 2022/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface MSMenuCellData: NSObject

@property(nonatomic,copy) NSString *normalPath;

@property(nonatomic,copy) NSString *selectPath;

@property(nonatomic,assign) BOOL isSelected;

@end
@interface MSMenuCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *menu;

- (void)setData:(MSMenuCellData *)data;


@end

NS_ASSUME_NONNULL_END
