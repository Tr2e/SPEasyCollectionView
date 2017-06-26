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

@property (nonatomic, strong) NSMutableArray *activeCells;
@property (nonatomic, strong) UIView *snapViewForActiveCell;
@property (nonatomic, assign) BOOL isEqualOrGreaterThan9_0;
@property (nonatomic, assign) CGPoint centerOffset;
@property (nonatomic, weak) UILongPressGestureRecognizer *longGestureRecognizer;
@property (nonatomic, weak) SPBaseCell *activeCell;
@property (nonatomic, weak) NSIndexPath *activeIndexPath;

@end

NSString  * const ReuseIdentifier = @"SPCell";

@implementation SPEasyCollectionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeMainView];
        self.activeCells = [NSMutableArray array];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initializeMainView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 修正collectionView通过xib初始化时frame不准确
    _collectionView.frame = self.bounds;
    
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

#pragma mark - chain calls
- (SPEasyCollectionViewinset)sp_inset{
    return ^SPEasyCollectionView *(UIEdgeInsets(^inset)()){
        self.inset = inset();
        return self;
    };
}

- (SPEasyCollectionViewItemSize)sp_itemsize{
    return ^SPEasyCollectionView *(CGSize(^itemSize)()){
        self.itemSize = itemSize();
        return self;
    };
}

- (SPEasyCollectionViewMinLineSpace)sp_minLineSpace{
    return ^SPEasyCollectionView *(NSInteger(^minLineSpace)()){
        self.minLineSpace = minLineSpace();
        return self;
    };
}

- (SPEasyCollectionViewMinInterItemSpace)sp_minInterItemSpace{
    return ^SPEasyCollectionView *(NSInteger(^minInterItemSpace)()){
        self.minInterItemSpace = minInterItemSpace();
        return self;
    };
}

- (SPEasyCollectionViewScrollDirection)sp_scollDirection{
    return ^SPEasyCollectionView *(SPEasyScrollDirection(^direction)()){
        self.scrollDirection = direction();
        return self;
    };
}

- (SPEasyCollectionViewDelegate)sp_delegate{
    return ^SPEasyCollectionView *(id(^delegate)()){
        self.delegate = delegate();
        return self;
    };
}

- (SPEasyCollectionViewCellXibName)sp_xibName{
    return ^SPEasyCollectionView *(NSString *(^xibName)()){
        self.xibName = xibName();
        return self;
    };
}

- (SPEasyCollectionViewCellClassName)sp_cellClassName{
    return ^SPEasyCollectionView *(NSString *(^className)()){
        self.cellClassName = className();
        return self;
    };
}

#pragma mark - properties

- (void)setCanEdit:(BOOL)canEdit{
    _canEdit = canEdit;
    
    if (canEdit) {
        [self wakeupEditingMode];
    }
    
}

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

#pragma mark - Editing Model
- (void)wakeupEditingMode{
    
    [self addLongPressGestureRecognizer];
    
}

- (void)addLongPressGestureRecognizer{
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPress.minimumPressDuration = self.activeEditingModeTimeInterval?_activeEditingModeTimeInterval:2.0f;
    [self addGestureRecognizer:longPress];
    self.longGestureRecognizer = longPress;
    
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer{
    
    BOOL isSystemVersionEqualOrGreaterThen9_0 = NO;
    self.isEqualOrGreaterThan9_0 = isSystemVersionEqualOrGreaterThen9_0 = [UIDevice.currentDevice.systemVersion compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending;
    [self handleEditingMode:recognizer];
    
}

- (void)handleEditingMode:(UILongPressGestureRecognizer *)recognizer{
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self handleEditingMoveWhenGestureBegan:recognizer];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self handleEditingMoveWhenGestureChanged:recognizer];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self handleEditingMoveWhenGestureEnded:recognizer];
            break;
        }
        default: {
            [self handleEditingMoveWhenGestureCanceledOrFailed:recognizer];
            break;
        }
    }
    
}

- (void)handleEditingMoveWhenGestureBegan:(UILongPressGestureRecognizer *)recognizer{

    CGPoint pressPoint = [recognizer locationInView:self.collectionView];
    NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:pressPoint];
    SPBaseCell *cell = (SPBaseCell *)[_collectionView cellForItemAtIndexPath:selectIndexPath];
    self.activeIndexPath = selectIndexPath;
    self.activeCell = cell;
    cell.selected = YES;
    
    if (_isEqualOrGreaterThan9_0) {
        [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
    }else{
        self.snapViewForActiveCell = [cell snapshotViewAfterScreenUpdates:YES];
        self.snapViewForActiveCell.frame = cell.frame;
        cell.hidden = YES;
        [self.collectionView addSubview:self.snapViewForActiveCell];
        self.centerOffset = CGPointMake(pressPoint.x - cell.center.x, pressPoint.y - cell.center.y);
    }

}

- (void)handleEditingMoveWhenGestureChanged:(UILongPressGestureRecognizer *)recognizer{

    CGPoint pressPoint = [recognizer locationInView:self.collectionView];
    if (_isEqualOrGreaterThan9_0) {
        [self.collectionView updateInteractiveMovementTargetPosition:pressPoint];
    }else{
        _snapViewForActiveCell.center = CGPointMake(pressPoint.x - _centerOffset.x, pressPoint.y-_centerOffset.y);
        for (SPBaseCell *cell in self.collectionView.visibleCells)
        {
            NSIndexPath *currentIndexPath = [_collectionView indexPathForCell:cell];
            if ([_collectionView indexPathForCell:cell] == self.activeIndexPath) continue;
            
            CGFloat space_x = fabs(_snapViewForActiveCell.center.x - cell.center.x);
            CGFloat space_y = fabs(_snapViewForActiveCell.center.y - cell.center.y);
            // CGFloat space = sqrtf(powf(space_x, 2) + powf(space_y, 2));
            CGFloat size_x = cell.bounds.size.width;
            CGFloat size_y = cell.bounds.size.height;
            
            if (currentIndexPath.item > self.activeIndexPath.item)
            {
                [self.activeCells addObject:cell];
            }
            
            if (space_x <  size_x/2.0 && space_y < size_y/2.0)
            {
                NSMutableArray *tempArr = [self.datas mutableCopy];
                
                NSInteger activeRange = currentIndexPath.item - self.activeIndexPath.item;
                BOOL moveForward = activeRange > 0;
                NSInteger originIndex = 0;
                NSInteger targetIndex = 0;
    
                for (NSInteger i = 1; i <= labs(activeRange); i ++) {
                    
                    NSInteger moveDirection = moveForward?1:-1;
                    originIndex = self.activeIndexPath.item + i*moveDirection;
                    targetIndex = originIndex  - 1*moveDirection;

                    [_collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:originIndex inSection:currentIndexPath.section] toIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:currentIndexPath.section]];
                    
                    [tempArr exchangeObjectAtIndex:originIndex withObjectAtIndex:targetIndex];
                    
                }
    
                self.datas = [tempArr copy];
                self.activeIndexPath = currentIndexPath;
            }
        }
    }
}

- (void)handleEditingMoveWhenGestureEnded:(UILongPressGestureRecognizer *)recognizer{
    
    if (_isEqualOrGreaterThan9_0) {
        self.activeCell.selected = NO;
        [self.collectionView endInteractiveMovement];
    }else{
        [UIView animateWithDuration:0.25f animations:^{
            self.snapViewForActiveCell.center = self.activeCell.center;
        } completion:^(BOOL finished) {
            [self.snapViewForActiveCell removeFromSuperview];
            self.activeCell.selected = NO;
            self.activeCell.hidden = NO;
        }];
    }
    
}

- (void)handleEditingMoveWhenGestureCanceledOrFailed:(UILongPressGestureRecognizer *)recognizer{

    if (_isEqualOrGreaterThan9_0) {
        self.activeCell.selected = NO;
        [self.collectionView cancelInteractiveMovement];
    }else{
        [UIView animateWithDuration:0.25f animations:^{
            self.snapViewForActiveCell.center = self.activeCell.center;
        } completion:^(BOOL finished) {
            [self.snapViewForActiveCell removeFromSuperview];
            self.activeCell.selected = NO;
            self.activeCell.hidden = NO;
        }];
    }

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
    
    self.selectIndex?self.selectIndex(indexPath.row):nil;
    if ([self.delegate respondsToSelector:@selector(easyCollectionView:didSelectItemAtIndex:)]) {
        [self.delegate easyCollectionView:(SPEasyCollectionView *)collectionView didSelectItemAtIndex:indexPath.row];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    BOOL canChange = self.datas.count > sourceIndexPath.item && self.datas.count > destinationIndexPath.item;
    if (canChange) {
        NSMutableArray *tempArr = [self.datas mutableCopy];
        [tempArr exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        self.datas = [tempArr copy];
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
