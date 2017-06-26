//
//  SPBaseCell.m
//  SPEasyCollectionView
//
//  Created by Tree on 2017/4/6.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPBaseCell.h"

@interface SPBaseCell()
@property (nonatomic, strong) UIView *maskView;
@end

@implementation SPBaseCell

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.maskView.hidden = NO;
        [self addSubview:self.maskView];
        [self bringSubviewToFront:_maskView];
    }else{
        _maskView.hidden = YES;
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
}

- (UIView *)maskView{
    if (_maskView == nil) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.alpha = 0.4f;
        maskView.hidden = YES;
        _maskView = maskView;
    }
    return _maskView;
}

@end
