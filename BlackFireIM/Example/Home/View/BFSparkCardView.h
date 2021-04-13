//
//  BFSparkCardView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CardCellSwipeDirection) {
    CardCellSwipeDirectionNone = 0,
    CardCellSwipeDirectionLeft,
    CardCellSwipeDirectionRight,
};

@interface BFCardViewCell: UIView

/** 重用标识 */
@property (nonatomic, copy) NSString *reuseIdentifier;
/** 指定初始化方法 */
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
/** 移除cell */
- (void)removeFromSuperviewSwipe:(CardCellSwipeDirection)direction;

@end


@class BFSparkCardView;
@protocol BFSparkCardViewDataSource<NSObject>

@required
- (NSInteger)numberOfCountInCardView:(BFSparkCardView *)cardView;

- (BFCardViewCell *)cardView:(BFSparkCardView *)cardView cellForRowAtIndex:(NSInteger)index;

@end

@protocol BFSparkCardViewDelegate<NSObject>
@optional

- (void)cardView:(BFSparkCardView *)cardView didRemoveCell:(BFCardViewCell *)cell forRowAtIndex:(NSInteger)index direction:(CardCellSwipeDirection)direction;

- (void)cardView:(BFSparkCardView *)cardView didRemoveLastCell:(BFCardViewCell *)cell forRowAtIndex:(NSInteger)index;

- (void)cardView:(BFSparkCardView *)cardView didDisplayCell:(BFCardViewCell *)cell forRowAtIndex:(NSInteger)index;

- (void)cardView:(BFSparkCardView *)cardView didMoveCell:(BFCardViewCell *)cell forMovePoint:(CGPoint)point direction:(CardCellSwipeDirection)direction;

@end

@interface BFSparkCardView : UIView

/** 当前可视cells */
@property (nonatomic, readonly) NSArray<__kindof BFCardViewCell *> *visibleCells;
/** 当前显示最上层索引 */
@property (nonatomic, readonly) NSInteger currentFirstIndex;
/** 数据源 */
@property (nonatomic,weak) id<BFSparkCardViewDataSource> dataSource;
/** 代理 */
@property (nonatomic,weak) id<BFSparkCardViewDelegate> delegate;
/** 卡片可见数量(默认3) */
@property (nonatomic, assign) NSInteger visibleCount;
/** 行间距(默认10.0，可自行计算scale比例来做间距) */
@property (nonatomic, assign) CGFloat lineSpacing;
/** 列间距(默认10.0，可自行计算scale比例来做间距) */
@property (nonatomic, assign) CGFloat interitemSpacing;
/** 侧滑最大角度(默认15°) */
@property (nonatomic, assign) CGFloat maxAngle;
/** 最大移除距离(默认屏幕的1/4) */
@property (nonatomic, assign) CGFloat maxRemoveDistance;
/** 是否重复(默认NO) */
@property (nonatomic, assign) BOOL isRepeat;

/** 重载数据 */
- (void)reloadData;
- (void)reloadDataAnimated:(BOOL)animated;
/** 加载更多数据 */
- (void)reloadMoreData;
- (void)reloadMoreDataAnimated:(BOOL)animated;
/** 从index开始加载 */
- (void)reloadDataFormIndex:(NSInteger)index;
- (void)reloadDataFormIndex:(NSInteger)index animated:(BOOL)animated;
/** 注册cell */
- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
/** 获取缓存cell */
- (__kindof BFCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/** 获取index对应的cell */
- (nullable __kindof BFCardViewCell *)cellForRowAtIndex:(NSInteger)index;
/** 获取cell对应的index */
- (NSInteger)indexForCell:(BFCardViewCell *)cell;
/** 移除最上层cell */
- (void)removeTopCardViewFromSwipe:(CardCellSwipeDirection)direction;

@end

NS_ASSUME_NONNULL_END
