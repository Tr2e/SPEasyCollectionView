//
//  SPEasyCollectionView.m
//  SPEasyCollectionView
//
//  Created by Tree on 2017/4/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPEasyCollectionView.h"
#import "SPBaseCell.h"
#import "EasyTools.h"

#define SPEasyPageControlSize CGSizeMake(10,10)

@interface SPEasyCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSUInteger totalItemCount;
@property (nonatomic, weak) NSTimer *timer;

@end

NSString  * const ReuseIdentifier = @"SPCell";

@implementation SPEasyCollectionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeMainView];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initializeMainView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // register cell
    if (_cellClassName) {
        [_collectionView registerClass:NSClassFromString(_cellClassName) forCellWithReuseIdentifier:ReuseIdentifier];
    }
    
    if (_xibName) {// xib
        [_collectionView registerNib:[UINib nibWithNibName:_xibName bundle:nil] forCellWithReuseIdentifier:ReuseIdentifier];
    }
    
    // space
    _layout.minimumLineSpacing = _minLineSpace?_minLineSpace:0;
    _layout.minimumInteritemSpacing = _minInterItemSpace?_minInterItemSpace:0;
    
    // pageControl
    CGSize size = SPEasyPageControlSize;
    CGFloat width = size.width * 1.5;
    CGFloat height = size.height;
    CGFloat x = self.center.x - width/2;
    CGFloat y = self.bounds.size.height - height* 2;
    _pageControl.frame = CGRectMake( x, y, width, height);
    _pageControl.hidden = !_needAutoScroll;
    
}

#pragma mark - properties
- (void)setNeedAutoScroll:(BOOL)needAutoScroll{
    _needAutoScroll = needAutoScroll;
    
    [self invalidateTimer];
    if (needAutoScroll) {
        _collectionView.pagingEnabled = YES;
        [self setupTimer];
    }
}

- (void)setDatas:(NSArray *)datas{
    _datas = datas;
    
    _totalItemCount = _needAutoScroll?datas.count * 500:datas.count;
    [self setupPageControl];
    [self.collectionView reloadData];
}

- (void)setItemSize:(CGSize)itemSize{
    _itemSize = itemSize;
    _layout.itemSize = self.itemSize.width?CGSizeMake(_itemSize.width, _itemSize.height):CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (void)setMinInterItemSpace:(NSInteger)minInterItemSpace{
    _minInterItemSpace = minInterItemSpace;
}

- (void)setMinLineSpace:(NSInteger)minLineSpace{
    _minLineSpace = minLineSpace;
}

- (void)setBounces:(BOOL)bounces{
    _bounces = bounces;
    _collectionView.bounces = bounces;
}

- (void)setPageEnabled:(BOOL)pageEnabled{
    _pageEnabled = pageEnabled;
    _collectionView.pagingEnabled = pageEnabled;
}

- (void)setInset:(UIEdgeInsets)inset{
    _inset = inset;
    _collectionView.contentInset = inset;
}

- (void)setScrollDirection:(SPEasyScrollDirection)scrollDirection{
    _scrollDirection = scrollDirection;
    _layout.scrollDirection = (UICollectionViewScrollDirection)scrollDirection;
}

#pragma mark - main view
- (void)initializeMainView{
    
    // layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = _scrollDirection?UICollectionViewScrollDirectionVertical:UICollectionViewScrollDirectionHorizontal;

    _layout = layout;
    
    // collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate  = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
}

#pragma mark - Page Control
- (void)setupPageControl{

    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = _datas.count;
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.userInteractionEnabled = NO;
    pageControl.currentPage = [self getRealShownIndex:[self currentIndex]];
    _pageControl = pageControl;
    [self addSubview:pageControl];
    
}

#pragma mark - Timer
- (void)setupTimer{

    NSTimer *timer = [NSTimer timerWithTimeInterval:_timerInterval?_timerInterval:3 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _timer = timer;
    
}

- (void)invalidateTimer{
    
    [_timer invalidate];
    _timer = nil;
    
}


#pragma mark - scroll actions
- (void)autoScroll{

    if (!_totalItemCount) return;
    NSInteger currentIndex = [self currentIndex];
    NSInteger nextIndex = [self nextIndexWithCurrentIndex:currentIndex];
    [self scroll2Index:nextIndex];
    
}

- (void)scroll2Index:(NSInteger)index{

    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:index?YES:NO];
    
}

- (NSInteger)nextIndexWithCurrentIndex:(NSInteger)index{

    if (index == _totalItemCount - 1) {
        return 0;
    }else{
        return index + 1;
    }
    
}

- (NSInteger)currentIndex{
    
    if (_collectionView.frame.size.width == 0 || _collectionView.frame.size.height == 0) {
        return 0;
    }
    
    int index = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_collectionView.contentOffset.x + _layout.itemSize.width * 0.5) / _layout.itemSize.width;
    } else {
        index = (_collectionView.contentOffset.y + _layout.itemSize.height * 0.5) / _layout.itemSize.height;
    }

    return MAX(0, index);
}

#pragma mark - datasoure
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _totalItemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    SPBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    cell.data = self.datas[_needAutoScroll?[self getRealShownIndex:indexPath.item]:indexPath.item];
    return cell;

}

- (NSInteger)getRealShownIndex:(NSInteger)index{

    return index%_datas.count;
    
}

#pragma mark - delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectIndex?self.selectIndex(indexPath.item):nil;
    if ([self.delegate respondsToSelector:@selector(easyCollectionView:didSelectItemAtIndex:)]) {
        [self.delegate easyCollectionView:(SPEasyCollectionView *)collectionView didSelectItemAtIndex:indexPath.item];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!self.datas.count) return;
     _pageControl.currentPage = [self getRealShownIndex:[self currentIndex]];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_needAutoScroll) [self invalidateTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_needAutoScroll) [self setupTimer];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

- (void)dealloc{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
