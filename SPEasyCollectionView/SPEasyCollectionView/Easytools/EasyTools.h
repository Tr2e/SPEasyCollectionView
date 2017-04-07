//
//  EasyTools.h
//  SPNetworking
//
//  Created by Tree on 2016/11/29.
//  Copyright © 2016年 Tr2e. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EasyTools : NSObject


id loadViewFromXib(id classType,id owner);
id loadViewController(id classType,id owner);

/**
 *  加载Xib - xibName(string),owner
 */
id loadViewFromXibWithName(NSString *xibName,id owner);
/**
 *  加载ViewController - storyBoardName(string),identifier(string)
 */
id loadViewControllerFromStoryboard(NSString *name,NSString *identifier);


@end
