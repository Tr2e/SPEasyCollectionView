//
//  TestCell.m
//  SPEasyCollectionView
//
//  Created by Tree on 2017/4/7.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "TestCell.h"

@implementation TestCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setupUI{

    self.backgroundColor = [UIColor lightGrayColor];
    
}

@end
