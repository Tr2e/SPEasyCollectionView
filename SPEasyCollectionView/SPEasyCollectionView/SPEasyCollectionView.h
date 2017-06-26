//
//  SPEasyCollectionView.h
//  SPEasyCollectionView
//
//  Created by Tree on 2017/4/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPBaseCell;
@class SPEasyCollectionView;


typedef NS_ENUM(NSInteger,SPEasyScrollDirection) {

    SPEasyScrollDirectionVertical,
    SPEasyScrollDirectionHorizontal
    
};

typedef void(^SPEasyCollectionSelect)(NSInteger index);

// chain calls
typedef SPEasyCollectionView *(^SPEasyCollectionViewItemSize)(CGSize(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewinset)(UIEdgeInsets(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewMinLineSpace)(NSInteger(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewMinInterItemSpace)(NSInteger(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewScrollDirection)(SPEasyScrollDirection(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewDelegate)(id(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewCellXibName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewCellClassName)(NSString *(^)(void));


@protocol SPEasyCollectionViewDelegate <NSObject>
@optional

- (void)easyCollectionView:(SPEasyCollectionView *)collectionView didSelectItemAtIndex:(NSInteger )index;

@end


@interface SPEasyCollectionView : UIView

// Timer
@property (nonatomic, assign) BOOL needAutoScroll;
@property (nonatomic, assign) NSTimeInterval timerInterval;

// Register Cell
@property (nonatomic, strong) NSString *xibName;
@property (nonatomic, strong) NSString* cellClassName;


@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL pageEnabled;

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) UIEdgeInsets inset;
@property (nonatomic, assign) NSInteger minLineSpace;
@property (nonatomic, assign) NSInteger minInterItemSpace;
@property (nonatomic, assign) SPEasyScrollDirection scrollDirection;

// Edit
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) NSTimeInterval activeEditingModeTimeInterval;

// chain calls
@property (nonatomic, readonly) SPEasyCollectionViewinset sp_inset;
@property (nonatomic, readonly) SPEasyCollectionViewItemSize sp_itemsize;
@property (nonatomic, readonly) SPEasyCollectionViewMinLineSpace sp_minLineSpace;
@property (nonatomic, readonly) SPEasyCollectionViewScrollDirection sp_scollDirection;
@property (nonatomic, readonly) SPEasyCollectionViewMinInterItemSpace sp_minInterItemSpace;
@property (nonatomic, readonly) SPEasyCollectionViewDelegate sp_delegate;
@property (nonatomic, readonly) SPEasyCollectionViewCellXibName sp_xibName;
@property (nonatomic, readonly) SPEasyCollectionViewCellClassName sp_cellClassName;


@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, copy) SPEasyCollectionSelect selectIndex;
@property (nonatomic, weak) id<SPEasyCollectionViewDelegate> delegate;


@end
