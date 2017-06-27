//
//  TestCell.m
//  SPEasyCollectionView
//
//  Created by Tree on 2017/4/7.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "TestCell.h"

@interface TestCell()
@property (nonatomic, weak)UILabel *testLabel;
@end

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
    UILabel *numLabel = [[UILabel alloc] init];
    numLabel.textColor = [UIColor whiteColor];
    numLabel.contentMode = UIViewContentModeCenter;
    numLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    
    [self.contentView addSubview:numLabel];
    self.testLabel = numLabel;
    
}

- (void)setData:(id)data{
    [super setData:data];
    
    _testLabel.text = (NSString *)data;
    [_testLabel sizeToFit];
    _testLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
}

@end
