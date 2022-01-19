//
//  MSMenuView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/23.
//

#import "MSMenuView.h"
#import "MSIMSDK-UIKit.h"



@interface MSMenuView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *data;

@end
@implementation MSMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [_menuCollectionView reloadData];
    [self defaultLayout];
    [_menuCollectionView layoutIfNeeded];
    [_menuCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TInput_Background_Color_Dark];

    _sendButton = [[UIButton alloc] init];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_sendButton setTitle:TUILocalizableString(Send) forState:UIControlStateNormal];
    _sendButton.backgroundColor = RGBA(87, 190, 105, 1.0);
    [_sendButton addTarget:self action:@selector(sendUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
    
    _menuFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _menuFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _menuFlowLayout.minimumLineSpacing = 0;
    _menuFlowLayout.minimumInteritemSpacing = 0;
    //_menuFlowLayout.headerReferenceSize = CGSizeMake(TMenuView_Margin, 1);

    _menuCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_menuFlowLayout];
    [_menuCollectionView registerClass:[MSMenuCollectionViewCell class] forCellWithReuseIdentifier:TMenuCell_ReuseId];
    [_menuCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:TMenuCell_Line_ReuseId];
    _menuCollectionView.collectionViewLayout = _menuFlowLayout;
    _menuCollectionView.delegate = self;
    _menuCollectionView.dataSource = self;
    _menuCollectionView.showsHorizontalScrollIndicator = NO;
    _menuCollectionView.showsVerticalScrollIndicator = NO;
    _menuCollectionView.backgroundColor = self.backgroundColor;
    _menuCollectionView.alwaysBounceHorizontal = YES;
    [self addSubview:_menuCollectionView];
}

- (void)defaultLayout
{
    CGFloat buttonWidth = self.frame.size.height * 1.3;
    _sendButton.frame = CGRectMake(self.frame.size.width - buttonWidth, 0, buttonWidth, self.frame.size.height);
    _menuCollectionView.frame = CGRectMake(0, 0, self.frame.size.width - 2 * buttonWidth, self.frame.size.height);
}

- (void)sendUpInside:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(menuViewDidSendMessage:)]){
        [_delegate menuViewDidSendMessage:self];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _data.count * 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0){
        MSMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TMenuCell_ReuseId forIndexPath:indexPath];
        [cell setData:_data[indexPath.row / 2]];
        return cell;
    }
    else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TMenuCell_Line_ReuseId forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 != 0){
        return;
    }
    for (NSInteger i = 0; i < _data.count; ++i) {
        MSMenuCellData *data = _data[i];
        data.isSelected = (i == indexPath.row / 2);
    }
    [_menuCollectionView reloadData];
    if(_delegate && [_delegate respondsToSelector:@selector(menuView:didSelectItemAtIndex:)]){
        [_delegate menuView:self didSelectItemAtIndex:indexPath.row / 2];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0){
        CGFloat wh = collectionView.frame.size.height;
        return CGSizeMake(wh, wh);
    }
    else{
        return CGSizeMake(TLine_Heigh, collectionView.frame.size.height);
    }
}

- (void)scrollToMenuIndex:(MSFaceGroup *)group atIndex:(NSInteger)index
{
    for (NSInteger i = 0; i < _data.count; ++i) {
        MSMenuCellData *data = _data[i];
        data.isSelected = (i == index);
    }
    _sendButton.hidden = !group.needSendBtn;
    [_menuCollectionView reloadData];
}

@end
