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

typedef void(^SPEasyCollectionSelect)(NSInteger index);

typedef NS_ENUM(NSInteger,SPEasyScrollDirection) {

    SPEasyScrollDirectionVertical,
    SPEasyScrollDirectionHorizontal
    
};


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

@property (nonatomic, strong) NSArray *datas;


@property (nonatomic, copy) SPEasyCollectionSelect selectIndex;
@property (nonatomic, weak) id<SPEasyCollectionViewDelegate> delegate;


@end
