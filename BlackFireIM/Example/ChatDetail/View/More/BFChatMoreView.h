//
//  BFChatMoreView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import <UIKit/UIKit.h>
#import "BFInputMoreCell.h"

NS_ASSUME_NONNULL_BEGIN

@class BFChatMoreView;
@protocol BFChatMoreViewDelegate <NSObject>

/**
 *  点击某一moreCell后的回调
 *  您可以通过该回调响应用户的点击操作，对被点击的 cell 进行判断，并进行相对应的功能操作。
 *  本委托中调用了进一步 inputController: didSelectMoreCell: 这一委托。
 *  如果您想实现自定义更多单元的响应回调的话，您可以在上述函数中使用以下示例代码：
 *
 *
 *  @param moreView 委托者，更多视图。
 *  @param cell 被选择并传入的modeCell
 */
- (void)moreView:(BFChatMoreView *)moreView didSelectMoreCell:(BFInputMoreCell *)cell;

@end

@interface BFChatMoreView : UIView

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UICollectionView *moreCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *moreFlowLayout;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, weak) id<BFChatMoreViewDelegate> delegate;

- (void)setData:(NSArray *)data;


@end

NS_ASSUME_NONNULL_END
