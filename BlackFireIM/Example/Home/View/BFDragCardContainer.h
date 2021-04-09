//
//  BFDragCardContainer.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "BFDragCardView.h"


NS_ASSUME_NONNULL_BEGIN

@class BFDragCardContainer;
@protocol BFDragCardContainerDataSource <NSObject>

@required

/** 数据源个数 **/
- (NSInteger)numberOfRowsInDragCardContainer:(BFDragCardContainer *)container;

/** 显示数据源 **/
- (BFDragCardView *)container:(BFDragCardContainer *)container viewForRowsAtIndex:(NSInteger)index;

@end

@protocol BFDragCardContainerDelegate <NSObject>

@optional

/** 点击卡片回调 **/
- (void)container:(BFDragCardContainer *)container didSelectRowAtIndex:(NSInteger)index;

/** 拖到最后一张卡片 YES，空，可继续调用reloadData分页数据**/
- (void)container:(BFDragCardContainer *)container dataSourceIsEmpty:(BOOL)isEmpty;

/**  当前cardview 是否可以拖拽，默认YES **/
- (BOOL)container:(BFDragCardContainer *)container canDragForCardView:(BFDragCardView *)cardView;

/** 卡片处于拖拽中回调**/
- (void)container:(BFDragCardContainer *)container dargingForCardView:(BFDragCardView *)cardView direction:(ContainerDragDirection)direction widthRate:(float)widthRate heightRate:(float)heightRate;

/** 卡片拖拽结束回调（卡片消失） **/
- (void)container:(BFDragCardContainer *)container dragDidFinshForDirection:(ContainerDragDirection)direction forCardView:(BFDragCardView *)cardView;

@end

@interface BFDragCardContainer : UIView

- (instancetype)initWithFrame:(CGRect)frame configure:(BFDragConfig*)config;

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, weak, nullable) id <BFDragCardContainerDataSource> dataSource;

@property (nonatomic, weak, nullable) id <BFDragCardContainerDelegate> delegate;

/** 刷新数据 **/
- (void)reloadData;

/** 主动调用拖拽 **/
- (void)removeCardViewForDirection:(ContainerDragDirection)direction;

/** 获取显示当前卡片 **/
- (BFDragCardView *)getCurrentShowCardView;

/** 获取显示当前卡片的index **/
- (NSInteger)getCurrentShowCardViewIndex;

@end

NS_ASSUME_NONNULL_END
