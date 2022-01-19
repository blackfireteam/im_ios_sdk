//
//  MSMenuView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import <UIKit/UIKit.h>
#import "MSMenuCollectionViewCell.h"


NS_ASSUME_NONNULL_BEGIN

@class MSMenuView;
@class MSFaceGroup;
@protocol MSMenuViewDelegate <NSObject>

- (void)menuViewDidSendMessage:(MSMenuView *)menuView;

- (void)menuView:(MSMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;

@end

@interface MSMenuView : UIView

@property (nonatomic, strong) UIButton *sendButton;

@property(nonatomic,weak) id<MSMenuViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *menuCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *menuFlowLayout;

- (void)scrollToMenuIndex:(MSFaceGroup *)group atIndex:(NSInteger)index;

- (void)setData:(NSMutableArray *)data;

@end

NS_ASSUME_NONNULL_END
