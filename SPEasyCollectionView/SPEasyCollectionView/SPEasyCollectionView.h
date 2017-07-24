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
typedef SPEasyCollectionView *(^SPEasyCollectionViewHeaderSize)(CGSize(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewFooterSize)(CGSize(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewinset)(UIEdgeInsets(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewMinLineSpace)(NSInteger(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewMinInterItemSpace)(NSInteger(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewScrollDirection)(SPEasyScrollDirection(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewDelegate)(id(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewCellXibName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewCellClassName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewHeaderXibName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewHeaderClassName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewFooterXibName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewFooterClassName)(NSString *(^)(void));
typedef SPEasyCollectionView *(^SPEasyCollectionViewBackgroundColor)(UIColor *(^)(void));


@protocol SPEasyCollectionViewDelegate <NSObject>
@optional

- (void)easyCollectionView:(UICollectionView *)collectionView didSelectItemAtIndex:(NSInteger )index;

@end


@interface SPEasyCollectionView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;

// Timer
@property (nonatomic, assign) BOOL needAutoScroll;
@property (nonatomic, assign) NSTimeInterval timerInterval;
// Register cell
@property (nonatomic, copy) NSString *xibName;
@property (nonatomic, copy) NSString *cellClassName;
// Register Header
@property (nonatomic, copy) NSString *headerXibName;
@property (nonatomic, copy) NSString *headerClassName;
// Register Footer
@property (nonatomic, copy) NSString *footerXibName;
@property (nonatomic, copy) NSString *footerClassName;
// Header Size
@property (nonatomic, assign) CGSize headerSize;
// Footer Size
@property (nonatomic, assign) CGSize footerSize;
// Basic settings
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL pageEnabled;
// Appearance Settings
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) UIEdgeInsets inset;
@property (nonatomic, assign) NSInteger minLineSpace;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) NSInteger minInterItemSpace;
@property (nonatomic, assign) SPEasyScrollDirection scrollDirection;

// Edit
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) NSTimeInterval activeEditingModeTimeInterval;

// chain calls
@property (nonatomic, readonly) SPEasyCollectionViewinset sp_inset;
@property (nonatomic, readonly) SPEasyCollectionViewItemSize sp_itemsize;
@property (nonatomic, readonly) SPEasyCollectionViewHeaderSize sp_headersize;
@property (nonatomic, readonly) SPEasyCollectionViewFooterSize sp_footersize;
@property (nonatomic, readonly) SPEasyCollectionViewMinLineSpace sp_minLineSpace;
@property (nonatomic, readonly) SPEasyCollectionViewScrollDirection sp_scollDirection;
@property (nonatomic, readonly) SPEasyCollectionViewMinInterItemSpace sp_minInterItemSpace;
@property (nonatomic, readonly) SPEasyCollectionViewDelegate sp_delegate;
@property (nonatomic, readonly) SPEasyCollectionViewCellXibName sp_xibName;
@property (nonatomic, readonly) SPEasyCollectionViewCellClassName sp_cellClassName;
@property (nonatomic, readonly) SPEasyCollectionViewHeaderXibName sp_headerXibName;
@property (nonatomic, readonly) SPEasyCollectionViewHeaderClassName sp_headerClassName;
@property (nonatomic, readonly) SPEasyCollectionViewFooterXibName sp_footerXibName;
@property (nonatomic, readonly) SPEasyCollectionViewFooterClassName sp_footerClassName;
@property (nonatomic, readonly) SPEasyCollectionViewBackgroundColor sp_backgroundColor;


@property (nonatomic, copy) NSArray *datas;
@property (nonatomic, copy) NSArray *sectionDatas;

@property (nonatomic, copy) SPEasyCollectionSelect selectIndex;
@property (nonatomic, weak) id<SPEasyCollectionViewDelegate> delegate;


@end
