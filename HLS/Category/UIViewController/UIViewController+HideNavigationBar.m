//
//  UIViewController+HideNavigationBar.m
//  XDSSwift
//
//  Created by zhengda on 16/9/9.
//  Copyright © 2016年 zhengda. All rights reserved.
//

#import "UIViewController+HideNavigationBar.h"
#import <objc/runtime.h>
@implementation UIViewController (HideNavigationBar)

void hideNavigationBar_swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    IMP swizzledImp = method_getImplementation(swizzledMethod);
    char *swizzledTypes = (char *)method_getTypeEncoding(swizzledMethod);
    
    IMP originalImp = method_getImplementation(originalMethod);
    char *originalTypes = (char *)method_getTypeEncoding(originalMethod);
    
    BOOL success = class_addMethod(class,
                                   originalSelector,
                                   swizzledImp,
                                   swizzledTypes);
    if (success) {
        class_replaceMethod(class,
                            swizzledSelector,
                            originalImp,
                            originalTypes);
    }else {
        // 添加失败，表明已经有这个方法，直接交换
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load{
    hideNavigationBar_swizzleMethod(self,
                  @selector(viewWillAppear:),
                  @selector(hideNavigationBar_ViewWillAppear:));
}

- (void)hideNavigationBar_ViewWillAppear:(BOOL)animated{
    [self hideNavigationBar_ViewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.hidesTopBarWhenPushed
                                           animated:YES];
}


char * hidesTopBarWhenPushedKey = "hidesTopBarWhenPushed";
- (void)setHidesTopBarWhenPushed:(BOOL)hidesTopBarWhenPushed{
    objc_setAssociatedObject(self,
                             hidesTopBarWhenPushedKey,
                             @(hidesTopBarWhenPushed),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hidesTopBarWhenPushed{
    id hidesTopBarWhenPushed = objc_getAssociatedObject(self, hidesTopBarWhenPushedKey);
    return [hidesTopBarWhenPushed boolValue];
}

@end
