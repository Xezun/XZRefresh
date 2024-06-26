//
//  XZRefreshRuntime.m
//  XZRefresh
//
//  Created by 徐臻 on 2024/6/26.
//

#import "XZRefreshRuntime.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "XZRefreshManager.h"

@implementation XZRefreshRuntime

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidScroll:scrollView];
}

- (void)__xz_refresh_override_scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidScroll:scrollView];
    
    struct objc_super _super = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&_super, @selector(scrollViewDidScroll:), scrollView);
}

- (void)__xz_refresh_exchange_scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidScroll:scrollView];
    [self __xz_refresh_exchange_scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewWillBeginDragging:scrollView];
}

- (void)__xz_refresh_override_scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewWillBeginDragging:scrollView];
    
    struct objc_super _super = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&_super, @selector(scrollViewWillBeginDragging:), scrollView);
}

- (void)__xz_refresh_exchange_scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewWillBeginDragging:scrollView];
    [self __xz_refresh_exchange_scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [scrollView.xz_refreshManagerIfLoaded scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)__xz_refresh_override_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [scrollView.xz_refreshManagerIfLoaded scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    
    struct objc_super _super = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(struct objc_super *, SEL, id, CGPoint, CGPoint *))objc_msgSendSuper)(&_super, @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:), scrollView, velocity, targetContentOffset);
}

- (void)__xz_refresh_exchange_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [scrollView.xz_refreshManagerIfLoaded scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self __xz_refresh_exchange_scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)__xz_refresh_override_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    struct objc_super _super = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(struct objc_super *, SEL, id, BOOL))objc_msgSendSuper)(&_super, @selector(scrollViewDidEndDragging:willDecelerate:), scrollView, decelerate);
}

- (void)__xz_refresh_exchange_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self __xz_refresh_exchange_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDecelerating:scrollView];
}

- (void)__xz_refresh_override_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDecelerating:scrollView];
    
    struct objc_super _super = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&_super, @selector(scrollViewDidEndDecelerating:), scrollView);
}

- (void)__xz_refresh_exchange_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDecelerating:scrollView];
    [self __xz_refresh_exchange_scrollViewDidEndDecelerating:scrollView];
}

@end


/// 获取类 aClass 自身的实例方法，不包括从父类继承的方法。
static Method XZRefreshGetInstanceMethod(Class const aClass, SEL const selector) {
    Method method = NULL;
    
    unsigned int count = 0;
    Method *methods = class_copyMethodList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        if (method_getName(methods[i]) == selector) {
            method = methods[i];
            break;
        }
    }
    free(methods);
    
    return method;
}

BOOL XZRefreshAddMethod(Class const aClass, SEL const selector, Class source, SEL const selectorForOverride, SEL const selectorForExchange, const void * const _key) {
    if (objc_getAssociatedObject(aClass, _key)) return NO;
    
    // 方法已实现
    if ([aClass instancesRespondToSelector:selector]) {
        Method const oldMethod = XZRefreshGetInstanceMethod(aClass, selector);
        if (oldMethod == NULL) {
            // 方法由父类实现，自身未实现，重写方法
            Method      const mtd = class_getInstanceMethod(source, selectorForOverride);
            IMP         const imp = method_getImplementation(mtd);
            const char *const enc = method_getTypeEncoding(mtd);
            class_addMethod(aClass, selector, imp, enc);
        } else {
            // 方法已自身实现，先添加被交换的方法，然后交换实现
            Method sourceMethod = class_getInstanceMethod(source, selectorForExchange);
            IMP sourceIMP = method_getImplementation(sourceMethod);
            if (class_addMethod(aClass, selectorForExchange, sourceIMP, method_getTypeEncoding(sourceMethod))) {
                Method const newMethod = class_getInstanceMethod(aClass, selectorForExchange);
                method_exchangeImplementations(oldMethod, newMethod);
            }
        }
    } else {
        // 方法未实现，添加方法
        Method       const mtd = class_getInstanceMethod(source, selector);
        IMP          const imp = method_getImplementation(mtd);
        const char * const enc = method_getTypeEncoding(mtd);
        class_addMethod(aClass, selector, imp, enc);
    }
    
    objc_setAssociatedObject(aClass, _key, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    return YES;
}
