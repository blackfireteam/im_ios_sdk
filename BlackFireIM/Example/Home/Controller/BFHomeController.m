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


@interface BFHomeController()<BFDragCardContainerDelegate,BFDragCardContainerDataSource>

@property(nonatomic,strong) BFDragCardContainer *containter;

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
    self.containter = [[BFDragCardContainer alloc]initWithFrame:CGRectMake(0, 100, Screen_Width, 400)];
    self.containter.dataSource = self;
    self.containter.delegate = self;
    [self.view addSubview:self.containter];
    
}

#pragma mark -- BFDragCardContainerDelegate,BFDragCardContainerDataSource
- (NSInteger)numberOfRowsInYFLDragCardContainer:(YFLDragCardContainer *)container
{
    return self.names.count;
}

- (YFLDragCardView *)container:(YFLDragCardContainer *)container viewForRowsAtIndex:(NSInteger)index
{
    CardView *cardView = [[CardView alloc]initWithFrame:container.bounds];
    [cardView setImage:self.names[index] title:self.titles[index]];
    return cardView;
}

- (void)container:(YFLDragCardContainer *)container didSelectRowAtIndex:(NSInteger)index
{
    NSLog(@"didSelectRowAtIndex :%ld",(long)index);
}

- (void)container:(YFLDragCardContainer *)container dataSourceIsEmpty:(BOOL)isEmpty
{
    if (isEmpty) {
        [container  reloadData];
    }
}

- (BOOL)container:(YFLDragCardContainer *)container canDragForCardView:(YFLDragCardView *)cardView
{
    return YES;
}

- (void)container:(YFLDragCardContainer *)container dargingForCardView:(YFLDragCardView *)cardView direction:(ContainerDragDirection)direction widthRate:(float)widthRate  heightRate:(float)heightRate
{
    CardView*currentShowCardView = (CardView*)cardView;
    CGFloat scale = 1 + ((boundaryRation > fabs(widthRate) ? fabs(widthRate) : boundaryRation)) / 4;
    NSString  *scaleString =  [NSString stringWithFormat:@"%.2f",scale];
    NSNumber *number = [NSNumber numberWithFloat:scaleString.floatValue];
    direction = [number isEqual:@1] ? ContainerDragDefaults:direction;
    [currentShowCardView  setAnimationwithDriection:direction];
    
}

- (void)container:(YFLDragCardContainer *)container dragDidFinshForDirection:(ContainerDragDirection)direction forCardView:(YFLDragCardView *)cardView
{
    NSLog(@"disappear:%ld",(long)cardView.tag);
}


#pragma mark - Action Methods
- (void)dislikeAction:(UIButton*)sender
{
    [self.container removeCardViewForDirection:ContainerDragLeft];
    CardView *cardView = (CardView *)[self.container getCurrentShowCardView];
    [cardView setAnimationwithDriection:ContainerDragLeft];
    
}

- (void)likeAction:(UIButton*)sender
{
    [self.container removeCardViewForDirection:ContainerDragRight];
    CardView *cardView = (CardView *)[self.container getCurrentShowCardView];
    [cardView setAnimationwithDriection:ContainerDragRight];
}


@end
