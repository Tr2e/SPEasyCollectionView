//
//  ViewController.m
//  SPEasyCollectionView
//
//  Created by Tree on 2017/4/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "ViewController.h"
#import "SPEasyCollectionView.h"


@interface ViewController ()<SPEasyCollectionViewDelegate>
@property (nonatomic, weak) SPEasyCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SPEasyCollectionView *storyboardTest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 代码创建
    SPEasyCollectionView *easyView = [[SPEasyCollectionView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200)];
    easyView.delegate = self;
    easyView.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    easyView.scrollDirection = SPEasyScrollDirectionHorizontal;
    easyView.xibName = @"EasyCell";
    easyView.needAutoScroll = YES;
    easyView.datas = @[@"1",@"2",@"3",@"4"];
    
    [self.view addSubview:easyView];
    
    // storyboard
    _storyboardTest.selectIndex = ^(NSInteger index) {// 点击位置
        
    };
    
    NSMutableArray *datasM = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 40; i++) {
        [datasM addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    _storyboardTest.datas = [datasM copy];
    _storyboardTest.canEdit = YES;
    
    // chain calls
    _storyboardTest.sp_cellClassName(^NSString *{
        return @"TestCell";
    }).sp_itemsize(^CGSize{
        return CGSizeMake(100, 100);
    }).sp_minLineSpace(^NSInteger{
        return 20;
    }).sp_minInterItemSpace(^NSInteger{
        return 10;
    }).sp_scollDirection(^SPEasyScrollDirection{
        return SPEasyScrollDirectionVertical;
    }).sp_inset(^UIEdgeInsets{
        return UIEdgeInsetsMake(20, 20, 20, 20);
    }).sp_backgroundColor(^UIColor *{
        return [UIColor colorWithRed:173/255.0 green:216/255.0 blue:230/255.0 alpha:1];
    });//LightBLue 			#ADD8E6	173,216,230
    
}


// 点击位置
- (void)easyCollectionView:(SPEasyCollectionView *)collectionView didSelectItemAtIndex:(NSInteger)index{

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
