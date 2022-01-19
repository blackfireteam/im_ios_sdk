//
//  MSFaceView.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import <UIKit/UIKit.h>
#import "MSFaceCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MSFaceView;
@protocol MSFaceViewDelegate <NSObject>

/**
 *  滑动到指定表情分组后的回调。
 *  您可以通过该回调响应使用者的滑动操作，进而更新表情视图的信息，展示出新表情组内的表情。
 *
 *  @param faceView 委托者，表情视图。通常情况下表情视图只有且只有一个。
 *  @param index 滑动的目的组号索引。
 */
- (void)faceView:(MSFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index;

/**
 *  选择某一具体表情后的回调（索引定位）。
 *  您可以通过该回调实现：当点击字符串类型的表情（如[微笑]）时，将表情添加到输入条。当点击其他类型的表情时，直接发送该表情。
 *
 *  @param faceView 委托者，表情视图。通常情况下表情视图只有且只有一个。
 *  @param indexPath 索引路径，定位表情。index.section：表情所在分组；index.row：表情所在行。
 */
- (void)faceView:(MSFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  点击表情视图中 删除 按钮后的操作回调。
 *  您可以通过该回调实现：在 inputBar 中删除整个表情字符串，比如，对于“[微笑]”，直接删除中括号以及括号中间的内容，而不是仅删除最右侧”]“。
 *
 *  @param faceView 委托者，表情视图，通常情况下表情视图只有且只有一个。
 */
- (void)faceViewDidBackDelete:(MSFaceView *)faceView;

@end

@interface MSFaceGroup : NSObject

/**
 *  表情组索引号，从0开始。
 */
@property (nonatomic, assign) int groupIndex;

/**
 *  表情组路径
 *  用于保存表情组在系统中存放的路径。
 */
@property (nonatomic, strong) NSString *groupPath;

/**
 *  表情组总行数
 *  用于计算表情总数，进而定位每一个表情。
 */
@property (nonatomic, assign) int rowCount;

/**
 *  每行所包含的表情数
 *  用于计算表情总数，进而定位每一个表情。
 */
@property (nonatomic, assign) int itemCountPerRow;

/**
 *  表情信息组
 *  存储各个表情的 cellData
 */
@property (nonatomic, strong) NSMutableArray *faces;

/**
 *  删除标志位
 *  对于需要“删除”按钮的表情组，该位为 YES，否则为 NO。
 *  当该位为 YES 时，FaceView 会在表情视图右下角中显示一个“删除”图标，使您无需呼出键盘即可进行表情的删除操作。
 */
@property(nonatomic,assign) BOOL needBackDelete;

@property(nonatomic,assign) BOOL needSendBtn;

@property(nonatomic,copy) NSString *menuNormalPath;

@property(nonatomic,copy) NSString *menuSelectPath;

@end

@interface MSFaceView : UIView

/**
 *  线视图
 *  在视图中的分界线，使得表情视图与其他视图在视觉上区分，从而让表情视图在显示逻辑上更加清晰有序。
 */
@property (nonatomic, strong) UIView *lineView;

/**
 *  表情视图的 CollectionView
 *  包含多行表情，并配合 faceFlowLayout 进行灵活统一的视图布局。
 */
@property (nonatomic, strong) UICollectionView *faceCollectionView;

/**
 *  faceCollectionView 的流水布局
 *  配合 faceCollectionView，用来维护表情视图的布局，使表情排布更加美观。能够设置布局方向、行间距、cell 间距等。
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *faceFlowLayout;

/**
 *  分页控制
 *  用于实现表情的多页浏览，能够滑动切换表情页，在表情页下方以原点形式显示总页数以及当前页数等功能。
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *  委托变量，被委托者
 *  需要实现 TFaceViewDelegate 协议中要求的功能。
 */
@property (nonatomic, weak) id<MSFaceViewDelegate> delegate;

@property (nonatomic, strong,readonly) NSArray *faceGroups;

/**
 *  滑动到指定表情分组。
 *  根据用户点击的表情分组的下标，切换到对应的表情分组下。
 *
 *  @param index 目的分组的组号索引，从0开始。
 */
- (void)scrollToFaceGroupIndex:(NSInteger)index;

/**
 *  设置数据。
 *  用来进行 TUIFaceView 的初始化或在需要时更新 faceView 中的数据。
 *
 *  @param data 需要设置的数据（MSFaceGroup）。在此 NSArray 中存放的对象为 MSFaceGroup，即表情组。
 */
- (void)setData:(NSArray * _Nullable)data;

@end

NS_ASSUME_NONNULL_END
