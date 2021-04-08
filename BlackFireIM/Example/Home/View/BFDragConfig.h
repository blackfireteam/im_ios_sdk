//
//  BFDragConfig.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ContainerDragDirection)
{
    ContainerDragDefault,
    ContainerDragLeft,
    ContainerDragRight
};

// 边界比
static const CGFloat boundaryRation = 0.8f;
static const CGFloat secondCardScale = 0.95f;
static const CGFloat thirdCardScale = 0.90f;

@interface BFDragConfig : NSObject

@property(nonatomic,assign) ContainerDragDirection *direction;

/** 可见个数 默认为 3 **/
@property (nonatomic,assign) NSInteger visableCount;
/** 卡片边距 默认为10.0f **/
@property (nonatomic,assign) CGFloat containerEdge;
/** 卡片内边距 默认为5.0f **/
@property (nonatomic,assign) CGFloat cardEdge;
/** 卡片圆角  默认为10.0f **/
@property (nonatomic,assign) CGFloat cardCornerRadius;
/** 卡片边缘宽度 默认为0.45f **/
@property (nonatomic,assign) CGFloat cardCornerBorderWidth;
/** 卡片边缘颜色 **/
@property (nonatomic,strong) UIColor *cardBordColor;

@end

NS_ASSUME_NONNULL_END
