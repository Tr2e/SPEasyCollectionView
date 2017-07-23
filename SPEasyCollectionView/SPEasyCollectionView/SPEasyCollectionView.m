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

typedef NS_ENUM(NSInteger,SPDragDirection) {
    SPDragDirectionRight,
    SPDragDirectionLeft,
    SPDragDirectionUp,
    SPDragDirectionDown
};

@interface SPEasyCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

// Cycle Function Part
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSUInteger totalItemCount;
@property (nonatomic, weak) NSTimer *timer;

// Active Cell Part
@property (nonatomic, assign) BOOL isEqualOrGreaterThan9_0;
@property (nonatomic, assign) CGFloat edgeIntersectionOffset;
@property (nonatomic, assign) CGPoint centerOffset;
@property (nonatomic, assign) SPDragDirection dragDirection;
@property (nonatomic, weak) UILongPressGestureRecognizer *longGestureRecognizer;
@property (nonatomic, weak) NSIndexPath *activeIndexPath;
@property (nonatomic, weak) NSIndexPath *sourceIndexPath;
@property (nonatomic, weak) SPBaseCell *activeCell;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray *activeCells;
@property (nonatomic, strong) UIView *snapViewForActiveCell;
@property (nonatomic, assign) CGFloat changeRatio;

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
    
    // 修正collectionView通过xib初始化时frame不准确
    _collectionView.frame = self.bounds;
    
    // space
    _layout.minimumLineSpacing = _minLineSpace?_minLineSpace:0;
    _layout.minimumInteritemSpacing = _minInterItemSpace?_minInterItemSpace:0;
    
    // backgroundColor
    self.collectionView.backgroundColor = self.backgroundColor?_backgroundColor:[UIColor whiteColor];
    
    // pageControl
    CGSize size = SPEasyPageControlSize;
    CGFloat width = size.width * 1.5;
    CGFloat height = size.height;
    CGFloat x = self.center.x - width/2;
    CGFloat y = self.bounds.size.height - height* 2;
    _pageControl.frame = CGRectMake( x, y, width, height);
    _pageControl.hidden = !_needAutoScroll;
    
    // super
    [super layoutSubviews];

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

- (SPEasyCollectionViewBackgroundColor)sp_backgroundColor{
    return ^SPEasyCollectionView *(UIColor *(^backgroundColor)()){
        self.backgroundColor = backgroundColor();
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
    if (_needAutoScroll) {
        [self setupPageControl];
    }
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

- (void)setCellClassName:(NSString *)cellClassName{
    _cellClassName = cellClassName;
    [_collectionView registerClass:NSClassFromString(_cellClassName) forCellWithReuseIdentifier:ReuseIdentifier];
}

- (void)setXibName:(NSString *)xibName{
    _xibName = xibName;
    [_collectionView registerNib:[UINib nibWithNibName:_xibName bundle:nil] forCellWithReuseIdentifier:ReuseIdentifier];
}

#pragma mark - main view
- (void)initializeMainView{
    
    // layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = _scrollDirection?UICollectionViewScrollDirectionVertical:UICollectionViewScrollDirectionHorizontal;

    _layout = layout;
    
    // collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.delegate  = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
}

#pragma mark - Page Control
- (void)setupPageControl{

    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.hidden = YES;
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

- (void)setupCADisplayLink{

    if (self.displayLink) {
        return;
    }
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleEdgeIntersection)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = displayLink;
    
}

- (void)invalidateCADisplayLink{
    
    [self.displayLink setPaused:YES];
    [self.displayLink invalidate];
    self.displayLink = nil;
    
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

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{

}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer{
    
    BOOL isSystemVersionEqualOrGreaterThen9_0 = NO;
    self.isEqualOrGreaterThan9_0 = isSystemVersionEqualOrGreaterThen9_0 = [UIDevice.currentDevice.systemVersion compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending;
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
    self.sourceIndexPath = selectIndexPath;
    self.activeCell = cell;
    self.activeCell.selected = YES;
    
    self.centerOffset = CGPointMake(pressPoint.x - cell.center.x, pressPoint.y - cell.center.y);
    
    if (_isEqualOrGreaterThan9_0) {
        [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
    }else{
        self.snapViewForActiveCell = [cell snapshotViewAfterScreenUpdates:YES];
        self.snapViewForActiveCell.frame = cell.frame;
        cell.hidden = YES;
        [self.collectionView addSubview:self.snapViewForActiveCell];
    }

}

- (void)handleEditingMoveWhenGestureChanged:(UILongPressGestureRecognizer *)recognizer{

    CGPoint pressPoint = [recognizer locationInView:self.collectionView];
    if (_isEqualOrGreaterThan9_0) {
        [self.collectionView updateInteractiveMovementTargetPosition:pressPoint];
    }else{
        _snapViewForActiveCell.center = CGPointMake(pressPoint.x - _centerOffset.x, pressPoint.y-_centerOffset.y);
        [self handleExchangeOperation];
        [self detectEdge];
    }
    
}

- (void)handleExchangeOperation{

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
            [self handleCellExchangeWithSourceIndexPath:self.activeIndexPath destinationIndexPath:currentIndexPath];
            self.activeIndexPath = currentIndexPath;
        }
    }
    
}

- (void)handleDatasourceExchangeWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSMutableArray *tempArr = [self.datas mutableCopy];
    
    NSInteger activeRange = destinationIndexPath.item - sourceIndexPath.item;
    BOOL moveForward = activeRange > 0;
    NSInteger originIndex = 0;
    NSInteger targetIndex = 0;
    
    for (NSInteger i = 1; i <= labs(activeRange); i ++) {
        
        NSInteger moveDirection = moveForward?1:-1;
        originIndex = sourceIndexPath.item + i*moveDirection;
        targetIndex = originIndex  - 1*moveDirection;
        
        [tempArr exchangeObjectAtIndex:originIndex withObjectAtIndex:targetIndex];
        
    }
    self.datas = [tempArr copy];
    NSLog(@"##### %@ #####",self.datas);
}

- (void)handleCellExchangeWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath{

    NSInteger activeRange = destinationIndexPath.item - sourceIndexPath.item;
    BOOL moveForward = activeRange > 0;
    NSInteger originIndex = 0;
    NSInteger targetIndex = 0;
    
    for (NSInteger i = 1; i <= labs(activeRange); i ++) {
        
        NSInteger moveDirection = moveForward?1:-1;
        originIndex = sourceIndexPath.item + i*moveDirection;
        targetIndex = originIndex  - 1*moveDirection;

        if (!_isEqualOrGreaterThan9_0) {
            CGFloat time = 0.25 - 0.11*fabs(self.changeRatio);
            NSLog(@"time:%f",time);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:time];
            [_collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:originIndex inSection:sourceIndexPath.section] toIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:sourceIndexPath.section]];
            [UIView commitAnimations];

            NSLog(@"---> exchange %ld to %ld",(long)originIndex,(long)targetIndex);
            
        }
        

    }

}

- (void)handleEditingMoveWhenGestureEnded:(UILongPressGestureRecognizer *)recognizer{
    
    if (_isEqualOrGreaterThan9_0) {
        self.activeCell.selected = NO;
        [self.collectionView endInteractiveMovement];
    }else{

        [self.snapViewForActiveCell removeFromSuperview];
        self.activeCell.selected = NO;
        self.activeCell.hidden = NO;
        
        [self handleDatasourceExchangeWithSourceIndexPath:self.sourceIndexPath destinationIndexPath:self.activeIndexPath];
        [self invalidateCADisplayLink];
        self.edgeIntersectionOffset = 0;
        self.changeRatio = 0;
        
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
        
        [self invalidateCADisplayLink];
        self.edgeIntersectionOffset = 0;
        self.changeRatio = 0;
    }

}


static CGFloat edgeRange = 10;
static CGFloat velocityRatio = 5;
- (void)detectEdge{
    
    CGFloat baseOffset = 2;

    CGPoint snapView_minPoint = self.snapViewForActiveCell.frame.origin;
    CGFloat snapView_max_x = CGRectGetMaxX(_snapViewForActiveCell.frame);
    CGFloat snapView_max_y = CGRectGetMaxY(_snapViewForActiveCell.frame);
    
    // left
    if (snapView_minPoint.x - self.collectionView.contentOffset.x < edgeRange &&
        self.collectionView.contentOffset.x > 0){

        CGFloat intersection_x = edgeRange - (snapView_minPoint.x - self.collectionView.contentOffset.x);
        intersection_x = intersection_x < 2*edgeRange?2*edgeRange:intersection_x;
        self.changeRatio = intersection_x/(2*edgeRange);
        baseOffset = baseOffset * -1 -  _changeRatio* baseOffset *velocityRatio;
        self.edgeIntersectionOffset = floorf(baseOffset);
        self.dragDirection = SPDragDirectionLeft;
        [self setupCADisplayLink];
        NSLog(@"Drag left - vertical offset:%f",self.edgeIntersectionOffset);
        NSLog(@"CollectionView offset_X:%f",self.collectionView.contentOffset.x);
        
    }
    
    // up
    else if (snapView_minPoint.y - self.collectionView.contentOffset.y < edgeRange &&
             self.collectionView.contentOffset.y > 0){
        
        CGFloat intersection_y = edgeRange - (snapView_minPoint.y - self.collectionView.contentOffset.y);
        intersection_y = intersection_y > 2*edgeRange?2*edgeRange:intersection_y;
        self.changeRatio = intersection_y/(2*edgeRange);
        baseOffset = baseOffset * -1 -  _changeRatio* baseOffset *velocityRatio;
        self.edgeIntersectionOffset = floorf(baseOffset);
        self.dragDirection = SPDragDirectionUp;
        [self setupCADisplayLink];
        NSLog(@"Drag up - vertical offset:%f",self.edgeIntersectionOffset);
        NSLog(@"CollectionView offset_Y:%f",self.collectionView.contentOffset.y);

    }
    
    // right
    else if (snapView_max_x + edgeRange > self.collectionView.contentOffset.x + self.collectionView.bounds.size.width && self.collectionView.contentOffset.x + self.collectionView.bounds.size.width < self.collectionView.contentSize.width){
        
        CGFloat intersection_x = edgeRange - (self.collectionView.contentOffset.x + self.collectionView.bounds.size.width - snapView_max_x);
        intersection_x = intersection_x > 2*edgeRange ? 2*edgeRange:intersection_x;
        self.changeRatio = intersection_x/(2*edgeRange);
        baseOffset = baseOffset + _changeRatio * baseOffset * velocityRatio;
        self.edgeIntersectionOffset = floorf(baseOffset);
        self.dragDirection = SPDragDirectionRight;
        [self setupCADisplayLink];
        NSLog(@"Drag right - vertical offset:%f",self.edgeIntersectionOffset);
        NSLog(@"CollectionView offset_X:%f",self.collectionView.contentOffset.x);
        
    }
    
    // down
    else if (snapView_max_y + edgeRange > self.collectionView.contentOffset.y + self.collectionView.bounds.size.height && self.collectionView.contentOffset.y + self.collectionView.bounds.size.height < self.collectionView.contentSize.height){
        
        CGFloat intersection_y = edgeRange - (self.collectionView.contentOffset.y + self.collectionView.bounds.size.height - snapView_max_y);
        intersection_y = intersection_y > 2*edgeRange ? 2*edgeRange:intersection_y;
        self.changeRatio = intersection_y/(2*edgeRange);
        baseOffset = baseOffset +  _changeRatio* baseOffset * velocityRatio;
        self.edgeIntersectionOffset = floorf(baseOffset);
        self.dragDirection = SPDragDirectionDown;
        [self setupCADisplayLink];
        NSLog(@"Drag down - vertical offset:%f",self.edgeIntersectionOffset);
        NSLog(@"CollectionView offset_Y:%f",self.collectionView.contentOffset.y);
        
    }
    
    // default
    else{
        
        self.changeRatio = 0;
        
        if (self.displayLink)
        {
            [self invalidateCADisplayLink];
        }
    }
    
}

- (void)handleEdgeIntersection{
    
    [self handleExchangeOperation];

    switch (_scrollDirection) {
        case SPEasyScrollDirectionHorizontal:
        {
            if (self.collectionView.contentOffset.x + self.inset.left < 0 &&
                self.dragDirection == SPDragDirectionLeft){
                return;
            }
            if (self.collectionView.contentOffset.x >
                self.collectionView.contentSize.width - (self.collectionView.bounds.size.width - self.inset.left) &&
                self.dragDirection == SPDragDirectionRight){
                    return;
            }
            
            [self.collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x + self.edgeIntersectionOffset, _collectionView.contentOffset.y) animated:NO];
            self.snapViewForActiveCell.center = CGPointMake(_snapViewForActiveCell.center.x + self.edgeIntersectionOffset, _snapViewForActiveCell.center.y);
        }
            break;
        case SPEasyScrollDirectionVertical:
        {
            
            if (self.collectionView.contentOffset.y + self.inset.top< 0 &&
                self.dragDirection == SPDragDirectionUp) {
                return;
            }
            if (self.collectionView.contentOffset.y >
                self.collectionView.contentSize.height - (self.collectionView.bounds.size.height - self.inset.top) &&
                self.dragDirection == SPDragDirectionDown) {
                return;
            }
            
            [self.collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, _collectionView.contentOffset.y +  self.edgeIntersectionOffset) animated:NO];
            self.snapViewForActiveCell.center = CGPointMake(_snapViewForActiveCell.center.x, _snapViewForActiveCell.center.y + self.edgeIntersectionOffset);
        }
            break;
    }
    
}

#pragma mark - cycle scroll actions
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
    
    self.selectIndex?self.selectIndex([self getRealShownIndex:indexPath.item]):nil;
    if ([self.delegate respondsToSelector:@selector(easyCollectionView:didSelectItemAtIndex:)]) {
        [self.delegate easyCollectionView:collectionView didSelectItemAtIndex:[self getRealShownIndex:indexPath.item]];
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    return nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    BOOL canChange = self.datas.count > sourceIndexPath.item && self.datas.count > destinationIndexPath.item;
    if (canChange) {
        [self handleDatasourceExchangeWithSourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath];
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
