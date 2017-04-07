//
//  EasyTools.m
//  SPNetworking
//
//  Created by Tree on 2016/11/29.
//  Copyright © 2016年 Tr2e. All rights reserved.
//

#import "EasyTools.h"

@implementation EasyTools

id loadViewControllerFromXib(NSBundle *bundle,NSString *xibName,Class className,id owner,NSString *restorationIdentifier)
{
    UINib *nib = [UINib nibWithNibName:xibName bundle:bundle];
    
    NSArray *list;
    @try {
        list = [nib instantiateWithOwner:owner options:nil];
    }
    @catch (NSException *exception) {
        assert(NO);
    }
    @finally {
        
    }
    
    for(UIViewController *vc in list)
    {
        if([vc isMemberOfClass:className] && (restorationIdentifier == nil || [vc.restorationIdentifier isEqualToString:restorationIdentifier]) )
            return vc;
    }
    return nil;
    
}

id loadViewControllerWithIdentifier(id classType, id owner, NSString *identifier)
{
    NSString * className = [classType description];
    
    Class c = NSClassFromString(className);
    
    if (c == nil) {
        return nil;
    }
    return loadViewControllerFromXib(nil, className, c, owner, identifier);
}

id loadViewController(id classType,id owner)
{
    
    return loadViewControllerWithIdentifier(classType,owner,nil);
}

id loadViewFromXibWithName(NSString *xibName,id owner)
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:xibName owner:owner options:nil];
    
    for (NSObject *objec in objects) {
        if ([objec isKindOfClass:[UIView class]]) {
            return objec;
        }
    }
    return nil;
}

id loadViewFromXib(id classType,id owner)
{
    NSString *className = NSStringFromClass(classType);
    
    return [[[NSBundle mainBundle] loadNibNamed:className owner:owner options:nil] lastObject];
    //    return loadViewControllerWithIdentifier(classType, owner, nil);
}

id loadViewControllerFromStoryboard(NSString *name,NSString *identifier)
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *vc = nil;
    
    if (identifier == nil)
    {
        vc = [storyboard instantiateInitialViewController];
    }
    else
    {
        vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    
    if ([vc isKindOfClass:[UIViewController class]]) {
        return vc;
    }
    return nil;
}
@end
