//
//  XZRefreshRuntime.h
//  XZRefresh
//
//  Created by 徐臻 on 2024/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 为运行时，注入原生方法提供实现。
@interface XZRefreshRuntime : NSObject <UIScrollViewDelegate>
- (void)__xz_refresh_exchange_scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)__xz_refresh_override_scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)__xz_refresh_override_scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)__xz_refresh_exchange_scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)__xz_refresh_override_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)__xz_refresh_exchange_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)__xz_refresh_override_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)__xz_refresh_exchange_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)__xz_refresh_override_scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)__xz_refresh_exchange_scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end

/// 给类添加实例方法。
/// @param aClass 待添加方法的类
/// @param selector 方法名
/// @param source 复制方法实现的源
/// @param selectorForOverride 如果待添加的方法已由目标父类实现，使用此方法的实现重写
/// @param selectorForExchange 如果待添加的方法已由目标自身实现，使用此方法的实现交换（先将方法添加到目标上）
/// @param _key 判断是否已经添加方法的标记
UIKIT_EXTERN BOOL XZRefreshAddMethod(Class const aClass, SEL const selector, Class source, SEL const selectorForOverride, SEL const selectorForExchange, const void * const _key);


NS_ASSUME_NONNULL_END
