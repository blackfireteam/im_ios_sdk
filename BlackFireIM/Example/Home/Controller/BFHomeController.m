//
//  BFHomeController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFHomeController.h"
#import "BFHomeCardView.h"
#import "BFDragCardContainer.h"
#import "BFHeader.h"
#import "UIView+Frame.h"
#import "MSIMSDK.h"
#import <SVProgressHUD.h>


@interface BFHomeController()<BFDragCardContainerDelegate,BFDragCardContainerDataSource>

@property(nonatomic,strong) BFDragCardContainer *containter;

@property(nonatomic,strong) NSMutableArray *dataList;

@end
@implementation BFHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"SPARK";
    
    [self setupUI];
}

- (void)setupUI
{
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setImage:[UIImage imageNamed:@"card_like"] forState:UIControlStateNormal];
    [likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    likeBtn.frame = CGRectMake(Screen_Width*0.5+30, Screen_Height-TabBar_Height-20-60, 60, 60);
    [self.view addSubview:likeBtn];
    
    UIButton *dislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dislikeBtn setImage:[UIImage imageNamed:@"card_dislike"] forState:UIControlStateNormal];
    [dislikeBtn addTarget:self action:@selector(dislikeAction:) forControlEvents:UIControlEventTouchUpInside];
    dislikeBtn.frame = CGRectMake(Screen_Width*0.5-30-60, Screen_Height-TabBar_Height-20-60, 60, 60);
    [self.view addSubview:dislikeBtn];
    
    UIButton *recallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recallBtn setImage:[UIImage imageNamed:@"card_recall"] forState:UIControlStateNormal];
    [recallBtn addTarget:self action:@selector(cardRecallAction:) forControlEvents:UIControlEventTouchUpInside];
    recallBtn.frame = CGRectMake(20, likeBtn.centerY-21, 42, 42);
    [self.view addSubview:recallBtn];
    
    self.containter = [[BFDragCardContainer alloc]initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height + 10, Screen_Width, likeBtn.y-10-StatusBar_Height-NavBar_Height-10)];
    self.containter.dataSource = self;
    self.containter.delegate = self;
    [self.view addSubview:self.containter];
    
    self.dataList = [NSMutableArray array];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MSIMManager sharedInstance] getSparks:^(NSArray<MSProfileInfo *> * sparks) {
            [self.dataList addObjectsFromArray:sparks];
            [self.containter reloadData];
            
            } fail:^(NSInteger code, NSString * _Nonnull desc) {
                [SVProgressHUD showInfoWithStatus:desc];
        }];
    });
}

#pragma mark -- BFDragCardContainerDelegate,BFDragCardContainerDataSource
- (NSInteger)numberOfRowsInDragCardContainer:(BFDragCardContainer *)container
{
    return self.dataList.count;
}

- (BFDragCardView *)container:(BFDragCardContainer *)container viewForRowsAtIndex:(NSInteger)index
{
    BFHomeCardView *cardView = [[BFHomeCardView alloc]initWithFrame:container.bounds];
    [cardView configItem:self.dataList[index]];
    return cardView;
}

- (void)container:(BFDragCardContainer *)container didSelectRowAtIndex:(NSInteger)index
{
    NSLog(@"didSelectRowAtIndex :%ld",(long)index);
}

- (void)container:(BFDragCardContainer *)container dataSourceIsEmpty:(BOOL)isEmpty
{
    if (isEmpty) {
        [container  reloadData];
    }
}

- (BOOL)container:(BFDragCardContainer *)container canDragForCardView:(BFDragCardView *)cardView
{
    return YES;
}

- (void)container:(BFDragCardContainer *)container dargingForCardView:(BFDragCardView *)cardView direction:(ContainerDragDirection)direction widthRate:(float)widthRate  heightRate:(float)heightRate
{
    BFHomeCardView *currentShowCardView = (BFHomeCardView *)cardView;
    CGFloat scale = 1 + ((boundaryRation > fabs(widthRate) ? fabs(widthRate) : boundaryRation)) / 4;
    NSString  *scaleString =  [NSString stringWithFormat:@"%.2f",scale];
    NSNumber *number = [NSNumber numberWithFloat:scaleString.floatValue];
    direction = [number isEqual:@1] ? ContainerDragDefault:direction;
    [currentShowCardView  setAnimationwithDriection:direction];

}

- (void)container:(BFDragCardContainer *)container dragDidFinshForDirection:(ContainerDragDirection)direction forCardView:(BFDragCardView *)cardView
{
    NSLog(@"disappear:%ld",(long)cardView.tag);
}


#pragma mark - Action Methods
- (void)dislikeAction:(UIButton *)sender
{
    [self.containter removeCardViewForDirection:ContainerDragLeft];
    BFHomeCardView *cardView = (BFHomeCardView *)[self.containter getCurrentShowCardView];
    [cardView setAnimationwithDriection:ContainerDragLeft];
}

- (void)likeAction:(UIButton *)sender
{
    [self.containter removeCardViewForDirection:ContainerDragRight];
    BFHomeCardView *cardView = (BFHomeCardView *)[self.containter getCurrentShowCardView];
    [cardView setAnimationwithDriection:ContainerDragRight];
}

- (void)cardRecallAction:(UIButton *)sender
{
    
}

@end
