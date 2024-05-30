//
//  XZRefreshManager.m
//  XZRefresh
//
//  Created by Xezun on 2023/8/10.
//

#import "XZRefreshManager.h"
#import "XZRefreshView.h"
#import "XZRefreshStyle1View.h"
#import "XZRefreshStyle2View.h"
#import "UIScrollView+XZRefresh.h"
#import "XZRefreshContext.h"
#import "XZRefreshDefines.h"

#define XZRefreshAsync(completion, ...)  if(completion){dispatch_async(dispatch_get_main_queue(),^{completion(__VA_ARGS__);});}

UIKIT_STATIC_INLINE void XZRefreshAnimate(BOOL animated, void (^animations)(void), void (^completion)(BOOL finished)) {
    if (animated) {
        [UIView animateWithDuration:XZRefreshAnimationDuration animations:animations completion:completion];
    } else {
        animations();
        XZRefreshAsync(completion, NO);
    }
}

UIKIT_STATIC_INLINE UIEdgeInsets XZRefreshAddBottom(UIEdgeInsets insets, CGFloat bottom) {
    insets.bottom += bottom;
    return insets;
}

UIKIT_STATIC_INLINE UIEdgeInsets XZRefreshAddTop(UIEdgeInsets insets, CGFloat top) {
    insets.top += top;
    return insets;
}

/// 给类添加实例方法。
/// @param aClass 待添加方法的类
/// @param selector 方法名
/// @param source 复制方法实现的源
/// @param selectorForOverride 如果待添加的方法已由目标父类实现，使用此方法的实现重写
/// @param selectorForExchange 如果待添加的方法已由目标自身实现，使用此方法的实现交换（先将方法添加到目标上）
/// @param _key 判断是否已经添加方法的标记
static BOOL XZRefreshAddMethod(Class const aClass, SEL const selector, Class source, SEL const selectorForOverride, SEL const selectorForExchange, const void * const _key);

/// 为运行时，注入原生方法提供实现。
@interface XZRefreshScrollViewDelegate : NSObject <UIScrollViewDelegate>
@end
@interface XZRefreshPlaceholderDelegate : XZRefreshScrollViewDelegate
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

// 监听 UIScrollView 代理 delegate 的标记。
static void const * const _context = &_context;

@implementation XZRefreshManager {
    /// 记录了 Header 或 Footer 的可见高度：负数为 Header 正数为 Footer 。
    CGFloat _distance;
    XZRefreshContext *_header;
    XZRefreshContext *_footer;
}

- (instancetype)initWithScrollView:(UIScrollView * const)scrollView {
    self = [super init];
    if (self != nil) {
        _scrollView = scrollView;
        
        _header = [XZRefreshContext headerContextForScrollView:scrollView];
        _footer = [XZRefreshContext footerContextForScrollView:scrollView];
        
        NSKeyValueObservingOptions const options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [scrollView addObserver:self forKeyPath:@"delegate" options:options context:(void *)_context];
        [scrollView addObserver:self forKeyPath:@"contentSize" options:options context:(void *)_context];
        [self scrollView:scrollView delegateDidChange:scrollView.delegate];
    }
    return self;
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"delegate" context:(void *)_context];
    [_scrollView removeObserver:self forKeyPath:@"contentSize" context:(void *)_context];
    _scrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != _context) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize const old = [change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize const new = [change[NSKeyValueChangeNewKey] CGSizeValue];
        if (CGSizeEqualToSize(new, old)) {
            return;
        }
        // 理论上来讲，contentSize 改变，不会影响 header
        // 1、页面大小发生改变
        // 2、下拉刷新，或上拉加载，导致页面内容变化
        [self setNeedsLayoutFooterRefreshView];
        return;
    }
    
    if ([keyPath isEqualToString:@"delegate"]) {
        // 当 delegate 改变时，重新监听 UIScrollViewDelegate 事件
        id<UIScrollViewDelegate> const old = change[NSKeyValueChangeOldKey];
        id<UIScrollViewDelegate> const new = change[NSKeyValueChangeNewKey];
        if (old == new) {
            return;
        }
        [self scrollView:object delegateDidChange:new];
        return;
    }
}

/// 接管代理事件。
- (void)scrollView:(UIScrollView *)scrollView delegateDidChange:(nullable id<UIScrollViewDelegate> const)delegate {
    if (delegate == self) {
        return;
    }
    if (delegate == nil) {
        scrollView.delegate = self;
        return;
    }
    
    Class  const target = delegate.class;
    Class  const source = [XZRefreshPlaceholderDelegate class];
    
    // 监听 scrollViewDidScroll: 方法。
    static const void * const key1 = &key1;
    SEL const m10 = @selector(scrollViewDidScroll:);
    SEL const m11 = @selector(__xz_refresh_override_scrollViewDidScroll:);
    SEL const m12 = @selector(__xz_refresh_exchange_scrollViewDidScroll:);
    BOOL const hasExchanged1 = XZRefreshAddMethod(target, m10, source, m11, m12, key1);
    
    // 监听 scrollViewWillEndDragging:withVelocity:targetContentOffset: 方法。
    static const void * const key2 = &key2;
    SEL const m20 = @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:);
    SEL const m21 = @selector(__xz_refresh_override_scrollViewWillEndDragging:withVelocity:targetContentOffset:);
    SEL const m22 = @selector(__xz_refresh_exchange_scrollViewWillEndDragging:withVelocity:targetContentOffset:);
    BOOL const hasExchanged2 = XZRefreshAddMethod(target, m20, source, m21, m22, key2);
    
    static const void * const key3 = &key3;
    SEL const m30 = @selector(scrollViewDidEndDecelerating:);
    SEL const m31 = @selector(__xz_refresh_override_scrollViewDidEndDecelerating:);
    SEL const m32 = @selector(__xz_refresh_exchange_scrollViewDidEndDecelerating:);
    BOOL const hasExchanged3 = XZRefreshAddMethod(target, m30, source, m31, m32, key3);
    
    static const void * const key4 = &key4;
    SEL const m40 = @selector(scrollViewWillBeginDragging:);
    SEL const m41 = @selector(__xz_refresh_override_scrollViewWillBeginDragging:);
    SEL const m42 = @selector(__xz_refresh_exchange_scrollViewWillBeginDragging:);
    BOOL const hasExchanged4 = XZRefreshAddMethod(target, m40, source, m41, m42, key4);
    
    static const void * const key5 = &key5;
    SEL const m50 = @selector(scrollViewDidEndDragging:willDecelerate:);
    SEL const m51 = @selector(__xz_refresh_override_scrollViewDidEndDragging:willDecelerate:);
    SEL const m52 = @selector(__xz_refresh_exchange_scrollViewDidEndDragging:willDecelerate:);
    BOOL const hasExchanged5 = XZRefreshAddMethod(target, m50, source, m51, m52, key5);
    
    // UIScrollView 对代理进行了优化，在设置代理时，获取了代理 scrollViewDidScroll: 的方法实现，
    // 发送事件时，直接执行 Method ，为了让动态添加的方法生效，需要重新设置一遍代理。
    // 重复设置 delegate 无效，因为值未改变，UIScrollView 不会重新获取 Method 。
    if (hasExchanged1 || hasExchanged2 || hasExchanged3 || hasExchanged4 || hasExchanged5) {
        scrollView.delegate = self;
        scrollView.delegate = delegate;
    }
}

- (void)setHeaderRefreshView:(XZRefreshView *)headerRefreshView {
    if (_header.view == headerRefreshView) {
        return;
    }
    if (_footer.view == headerRefreshView) {
        [self setFooterRefreshView:nil];
    }
    
    [_header.view removeFromSuperview];
    headerRefreshView.refreshManager = self;
    _header.view = headerRefreshView;
    if (headerRefreshView != nil) {
        [_scrollView addSubview:headerRefreshView];
    }
    
    [self setNeedsLayoutHeaderRefreshView];
}

- (void)setFooterRefreshView:(XZRefreshView *)footerRefreshView {
    if (_footer.view == footerRefreshView) {
        return;
    }
    if (_header.view == footerRefreshView) {
        [self setHeaderRefreshView:nil];
    }
    
    [_footer.view removeFromSuperview];
    footerRefreshView.refreshManager = self;
    _footer.view = footerRefreshView;
    if (footerRefreshView != nil) {
        [_scrollView addSubview:footerRefreshView];
    }
    
    [self setNeedsLayoutFooterRefreshView];
}

- (XZRefreshView *)headerRefreshView {
    if (_header.view != nil) {
        return _header.view;
    }
    UIScrollView *  const _scrollView = self->_scrollView;
    CGFloat         const y           = -_scrollView.adjustedContentInset.top - XZRefreshHeight;
    XZRefreshView * const refreshView = [[XZRefreshStyle1View alloc] initWithFrame:CGRectMake(0, y, _scrollView.frame.size.width, XZRefreshHeight)];
    
    refreshView.refreshManager = self;
    _header.view = refreshView;
    [_scrollView addSubview:refreshView];
    
    [self setNeedsLayoutHeaderRefreshView];
    return refreshView;
}

- (XZRefreshView *)footerRefreshView {
    if (_footer.view != nil) {
        return _footer.view;
    }
    UIScrollView *  const _scrollView = self->_scrollView;
    UIEdgeInsets    const insets = _scrollView.adjustedContentInset;
    CGRect          const bounds = _scrollView.bounds;
    CGFloat         const y      = MAX(_scrollView.contentSize.height, bounds.size.height - insets.top - insets.bottom) + insets.bottom;
    XZRefreshView * const refreshView = [[XZRefreshStyle2View alloc] initWithFrame:CGRectMake(0, y, bounds.size.width, XZRefreshHeight)];
    
    refreshView.refreshManager = self;
    _footer.view = refreshView;
    [_scrollView addSubview:refreshView];
    
    [self setNeedsLayoutFooterRefreshView];
    return refreshView;
}

- (XZRefreshView *)headerRefreshViewIfLoaded {
    return _header.view;
}

- (XZRefreshView *)footerRefreshViewIfLoaded {
    return _footer.view;
}

- (void)setNeedsLayoutHeaderRefreshView {
    if (_header.needsLayout) {
        return;
    }
    _header.needsLayout = YES;
    __weak typeof(self) wself = self;
    [NSRunLoop.mainRunLoop performBlock:^{
        [wself layoutHeaderRefreshViewIfNeeded];
    }];
}

- (void)setNeedsLayoutFooterRefreshView {
    if (_footer.needsLayout) {
        return;
    }
    _footer.needsLayout = YES;
    __weak typeof(self) wself = self;
    [NSRunLoop.mainRunLoop performBlock:^{
        [wself layoutFooterRefreshViewIfNeeded];
    }];
}

- (void)setNeedsLayoutRefreshViews {
    [self setNeedsLayoutHeaderRefreshView];
    [self setNeedsLayoutFooterRefreshView];
}

- (void)layoutRefreshViewsIfNeeded {
    [self layoutHeaderRefreshViewIfNeeded];
    [self layoutFooterRefreshViewIfNeeded];
}

// 头部刷新视图默认布局在可视区域之上，即，刷新视图的底部与可视区域的顶部对齐，
// 值为 -adjustedInsets.top - frame.size.height 。
// 偏移值为默认默认布局基础之上，按 offset 向上偏移 -offset 。
// 在动画时，contentInsets.top 相比原始值多一个 animationHeight，因此先计算出原始的 top 值，
// 即 contentInsets.top - animationHeight 。
- (void)layoutHeaderRefreshViewIfNeeded {
    XZRefreshContext *_header = self->_header;
    if (!_header.needsLayout) {
        return;
    }
    _header.needsLayout = NO;

    XZRefreshView * const _refreshView = _header.view;
    if (_refreshView == nil) {
        return;
    }
    
    UIScrollView * const _scrollView  = self->_scrollView;
    CGRect         const bounds       = _scrollView.bounds;
    
    switch (_header.state) {
        case XZRefreshStateRefreshing:
        case XZRefreshStateWillRecovering: {
            // 保存参数：在刷新的过程中，如果调整了刷新高度，将差值合并到边距上。
            // 调整 contentInset 可能引起的 UIScrollView 滚动，由具体的业务逻辑处理。
            CGFloat const oldHeight = _header.height;
            CGFloat const newHeight = _refreshView.height;
            if (newHeight != oldHeight) {
                _scrollView.contentInset = XZRefreshAddTop(_scrollView.contentInset, newHeight - oldHeight);
                _header.height = newHeight;
            }
            _header.adjustment = _refreshView.adjustment;
            _header.offset     = _refreshView.offset;
            
            // 刷新高度已经合并，所以直接使用 contentInsets 进行计算。
            UIEdgeInsets const contentInsets = _scrollView.adjustedContentInset;
            UIEdgeInsets const layoutInsets = _header.layoutInsets;
            
            CGFloat const w = CGRectGetWidth(bounds);
            CGFloat const h = CGRectGetHeight(_refreshView.frame);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = -(layoutInsets.top - _header.height) - h;
            CGRect  const frame = CGRectMake(x, y - _header.offset, w, h);
            
            _header.frame = frame;
            _header.contentOffsetY = -contentInsets.top;
            _refreshView.frame = frame;
            break;
        }
        default: {
            _header.height     = _refreshView.height;
            _header.adjustment = _refreshView.adjustment;
            _header.offset     = _refreshView.offset;
            
            UIEdgeInsets const layoutInsets = _header.layoutInsets;
            
            CGFloat const w = CGRectGetWidth(bounds);
            CGFloat const h = CGRectGetHeight(_refreshView.frame);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = -layoutInsets.top - h;
            CGRect  const frame = CGRectMake(x, y - _header.offset, w, h);
            
            _header.frame = frame;
            _header.contentOffsetY = -_scrollView.adjustedContentInset.top;
            _refreshView.frame = frame;
            break;
        }
    }
}

/// 尾部刷新视图的布局规则：
/// 一、不刷新时。
/// 刷新视图布局在页面底部之下，即，刷新视图的顶边，与可见区域的底边相同。
/// 因此可通过 scrollViewHeight 计算出撑满一屏为最小高度公式为
/// minHeight = scrollViewHeight - top - bottom 。
/// 二、正刷新时。
/// 在附加了底部刷新高度边距后，如果页面高度仍不满足一屏，刷新视图刷新放在底部，
/// 满足一屏，正常布局，放在页面尾部即可。
- (void)layoutFooterRefreshViewIfNeeded {
    XZRefreshContext * const _footer = self->_footer;
    if (!_footer.needsLayout) {
        return;
    }
    _footer.needsLayout = NO;
    
    XZRefreshView * const _refreshView = _footer.view;
    if (!_refreshView) {
        return;
    }
    
    UIScrollView * const _scrollView = self->_scrollView;
    CGRect         const bounds      = _scrollView.bounds;
    CGSize         const contentSize = _scrollView.contentSize;
    
    switch (_footer.state) {
        case XZRefreshStateRefreshing:
        case XZRefreshStateWillRecovering: {
            CGFloat const oldHeight = _footer.height;
            CGFloat const newHeight = _refreshView.height;
            if (newHeight != oldHeight) {
                _scrollView.contentInset = XZRefreshAddBottom(_scrollView.contentInset, newHeight - oldHeight);
                _footer.height = newHeight;
            }
            _footer.adjustment = _refreshView.adjustment;
            _footer.offset     = _refreshView.offset;
            
            // 底部在刷新的过程中，刷新高度已经附加到了边距之中，
            // 因此可通过实际边距进行计算，判断可滚动区域是否满足一屏，并决定如何布局刷新视图。
            UIEdgeInsets const contentInsets = _scrollView.adjustedContentInset;
            UIEdgeInsets const layoutInsets  = _footer.layoutInsets;
            BOOL         const mode = (contentInsets.top + contentSize.height + layoutInsets.bottom < bounds.size.height);
            
            CGFloat const w = CGRectGetWidth(bounds);
            CGFloat const h = CGRectGetHeight(_refreshView.frame);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = (mode ? (bounds.size.height - contentInsets.top - _footer.height) : (contentSize.height + layoutInsets.bottom - _footer.height));
            CGFloat const contentOffsetY = (mode ? -contentInsets.top : contentSize.height + contentInsets.bottom - bounds.size.height);
            CGRect  const frame = CGRectMake(x, y + _footer.offset, w, h);
            
            _footer.frame = frame;
            _footer.contentOffsetY = contentOffsetY;
            _footer.needsAnimatedTransitioning = (contentInsets.top + contentSize.height < bounds.size.height);
            _refreshView.frame = frame;
            break;
        }
        default: {
            _footer.height     = _refreshView.height;
            _footer.adjustment = _refreshView.adjustment;
            _footer.offset     = _refreshView.offset;
            
            UIEdgeInsets const layoutInsets  = _footer.layoutInsets;
            UIEdgeInsets contentInsets = _scrollView.adjustedContentInset;
            
            // 顶部在刷新时，顶部的边距需要减去刷新高度
            switch (_header.state) {
                case XZRefreshStateRefreshing:
                case XZRefreshStateWillRecovering: {
                    contentInsets.top -= _header.height;
                    break;
                }
                default: {
                    break;
                }
            }
            
            //
            BOOL const mode = (contentInsets.top + contentSize.height + layoutInsets.bottom < bounds.size.height);
            CGFloat const w = CGRectGetWidth(bounds);
            CGFloat const h = CGRectGetHeight(_refreshView.frame);
            CGFloat const x = CGRectGetMinX(bounds);
            CGFloat const y = (mode ? (bounds.size.height - contentInsets.top) : (contentSize.height + layoutInsets.bottom));
            CGFloat const contentOffsetY = (mode ? -contentInsets.top : contentSize.height + contentInsets.bottom - bounds.size.height);
            CGRect  const frame = CGRectMake(x, y + _footer.offset, w, h);
            
            _footer.frame = frame;
            _footer.contentOffsetY = contentOffsetY;
            _footer.needsAnimatedTransitioning = NO;
            _refreshView.frame = frame;
            break;
        }
    }
}

/// 判断指定的 HeaderFooterView 是否在动画中。
- (BOOL)isRefreshViewAnimating:(XZRefreshView *)refreshingView {
    if (refreshingView == _header.view) {
        switch (_header.state) {
            case XZRefreshStateRefreshing:
            case XZRefreshStateWillRefreshing:
                return YES;
            default:
                return NO;
        }
    }
    if (refreshingView == _footer.view) {
        switch (_footer.state) {
            case XZRefreshStateRefreshing:
            case XZRefreshStateWillRefreshing:
                return YES;
            default:
                return NO;
        }
    }
    return NO;
}

- (void)refreshingView:(XZRefreshView *)refreshingView beginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (refreshingView == _header.view) {
        [self beginHeaderRefreshing:animated completion:completion];
    } else if (refreshingView == _footer.view) {
        [self beginFooterRefreshing:animated completion:completion];
    } else {
        XZRefreshAsync(completion, NO);
    }
}

- (void)beginHeaderRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_header.state != XZRefreshStatePendinging || _footer.state != XZRefreshStatePendinging) {
        XZRefreshAsync(completion, NO);
        return;
    }
    // 避免初次调用时，可能还没有同步 context 值
    [self layoutHeaderRefreshViewIfNeeded];
    
    UIScrollView * const _scrollView = self->_scrollView;
    
    /// 在拖拽的过程中，改变 contentInset 可能会导致页面抖动。
    /// 因为 scrollView 在滚动区域内，手势平移的距离，就是页面滚动的距离，
    /// 但是在弹性区域内，滚动的距离不等于平移的距离，当 contentInset 改变后
    /// 手势平移的距离虽然没有变，但是由于可滚动区域发生了改变，
    /// 根据可滚动区域计算得到的页面平移的距离改变了，从而导致页面发生抖动。
    /// 但是由于这个变化不是立即触发的，无法在改变后立即修复页面位置，所以不能在
    /// 用户触摸的过程中调整 contentInset 故有此状态。
    if (_scrollView.isDragging) {
        _header.state = XZRefreshStateWillRefreshing;
        XZRefreshAsync(completion, NO);
    } else {
        _header.state = XZRefreshStateRefreshing;
        
        CGPoint const contentOffset = _scrollView.contentOffset;
        // 1、增加到 contentInset 的边距会叠加到 adjustedContentInset 中
        // 2、改变 contentInset 会触发 didScroll 方法，可能改变 contentOffset，所以必须先改变 state
        _scrollView.contentInset  = XZRefreshAddTop(_scrollView.contentInset, _header.height);
        _scrollView.verticalScrollIndicatorInsets = XZRefreshAddTop(_scrollView.verticalScrollIndicatorInsets, _header.height);
        _scrollView.contentOffset = contentOffset;
        
        // 因为动画的高度不一定是下拉刷新所需的距离，所以使用 -setContentOffset:animated: 方法未必能触发刷新。
        // 因此这里使用 UIViewAnimation 的方法，直接进入下拉刷新状态。
        XZRefreshAnimate(animated, ^{
            [self setNeedsLayoutHeaderRefreshView];
            [self layoutHeaderRefreshViewIfNeeded];
            _scrollView.contentOffset = CGPointMake(0, self->_header.contentOffsetY);
        }, completion);
    }
    
    // 通知刷新视图，进入刷新状态
    [_header.view scrollView:_scrollView didBeginRefreshing:animated];
}

- (void)beginFooterRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_footer.state != XZRefreshStatePendinging || _header.state != XZRefreshStatePendinging) {
        XZRefreshAsync(completion, NO);
        return;
    }
    [self layoutFooterRefreshViewIfNeeded];
    
    UIScrollView * const _scrollView = self->_scrollView;
    
    if (_scrollView.isDragging) {
        _footer.state = XZRefreshStateWillRefreshing;
        XZRefreshAsync(completion, NO);
    } else {
        _footer.state = XZRefreshStateRefreshing;
        
        // 调整 contentInset
        CGPoint const contentOffset = _scrollView.contentOffset;
        _scrollView.contentInset = XZRefreshAddBottom(_scrollView.contentInset, _footer.height);
        _scrollView.verticalScrollIndicatorInsets = XZRefreshAddBottom(_scrollView.verticalScrollIndicatorInsets, _footer.height);
        _scrollView.contentOffset = contentOffset;
        
        // 滚动到 footer
        XZRefreshAnimate(animated, ^{
            [self setNeedsLayoutFooterRefreshView];
            [self layoutFooterRefreshViewIfNeeded];
            _scrollView.contentOffset = CGPointMake(0, self->_footer.contentOffsetY);
        }, completion);
    }
    
    [_footer.view scrollView:_scrollView didBeginRefreshing:animated];
}

- (void)refreshingView:(XZRefreshView *)refreshingView endAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (refreshingView == _header.view) {
        [self endHeaderRefreshing:animated completion:completion];
    } else if (refreshingView == _footer.view) {
        [self endFooterRefreshing:animated completion:completion];
    } else {
        XZRefreshAsync(completion, NO);
    }
}

- (void)endHeaderRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_header.state != XZRefreshStateRefreshing) {
        XZRefreshAsync(completion, NO);
        return;
    }
    
    UIScrollView * const _scrollView   = self->_scrollView;
    CGPoint        const contentOffset = _scrollView.contentOffset;
    
    if (_scrollView.isDragging) {
        // 当拖拽时，结束刷新仅展示结束动画，布局调整在 -willEndDragging 中处理。
        _header.state = XZRefreshStateWillRecovering;
        // 使用 YES 标记，以通知刷新视图执行结束动画
        [_header.view scrollView:_scrollView willEndRefreshing:YES];
        // 理论上来说，此步骤并无必要。
        [self layoutHeaderRefreshViewIfNeeded];
        // NO 表示结束的动画在回调执行时没有完成
        XZRefreshAsync(completion, NO);
    } else {
        // 恢复 contentInset
        // 设置 contentInset/contentOffset 会触发 -scrollViewDidScroll: 方法。
        // 但是此时处于 refreshing 状态，-scrollViewDidScroll: 不执行任何操作。
        _scrollView.contentInset = XZRefreshAddTop(_scrollView.contentInset, -_header.height);
        _scrollView.verticalScrollIndicatorInsets = XZRefreshAddTop(_scrollView.verticalScrollIndicatorInsets, -_header.height);
        _scrollView.contentOffset = contentOffset;
        
        if (contentOffset.y >= _header.contentOffsetY + _header.height) {
            // 头部刷新视图不在展示区域内，不需要展示结束动画
            _header.state = XZRefreshStateRecovering;
            [_header.view scrollView:_scrollView willEndRefreshing:NO];
            
            [self setNeedsLayoutHeaderRefreshView];
            [self layoutHeaderRefreshViewIfNeeded];
            
            _header.state = XZRefreshStatePendinging;
            [_header.view scrollView:_scrollView didEndRefreshing:NO];
            XZRefreshAsync(completion, NO);
        } else {
            _header.state = XZRefreshStateRecovering;
            [_header.view scrollView:_scrollView willEndRefreshing:animated];
            
            XZRefreshAnimate(animated, ^{
                [self setNeedsLayoutHeaderRefreshView];
                [self layoutHeaderRefreshViewIfNeeded];
                _scrollView.contentOffset = CGPointMake(contentOffset.x, self->_header.contentOffsetY);
            }, ^(BOOL finished) {
                self->_header.state = XZRefreshStatePendinging;
                [self->_header.view scrollView:_scrollView didEndRefreshing:YES];
                XZRefreshAsync(completion, finished);
            });
        }
    }
}

- (void)endFooterRefreshing:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_footer.state != XZRefreshStateRefreshing) {
        XZRefreshAsync(completion, NO);
        return;
    }
    
    UIScrollView     * const _scrollView   = self->_scrollView;
    XZRefreshContext * const _footer       = self->_footer;
    
    if (_scrollView.isDragging) {
        _footer.state = XZRefreshStateWillRecovering;
        [_footer.view scrollView:_scrollView willEndRefreshing:YES];
        // 底部刷新往往发生在列表数据改变之后，即 contentSize 可能发生了改变。
        // 因此使用动画来调整刷新视图。
        XZRefreshAnimate(animated, ^{
            [self layoutFooterRefreshViewIfNeeded];
        }, ^(BOOL finished) {
            XZRefreshAsync(completion, NO);
        });
    } else {
        CGPoint const contentOffset = _scrollView.contentOffset;
        
        // 恢复边距
        _scrollView.contentInset = XZRefreshAddBottom(_scrollView.contentInset, -_footer.height);
        _scrollView.verticalScrollIndicatorInsets = XZRefreshAddBottom(_scrollView.verticalScrollIndicatorInsets, -_footer.height);
        _scrollView.contentOffset = contentOffset;
        
        if (contentOffset.y <= _footer.contentOffsetY - _footer.height) {
            // 尾部刷新视图没有在展示区域内，页面不需要动
            // 下拉加载更多后，footer 已经不展示在可见范围，footer 的动画在 kvo 时处理了
            _footer.state = XZRefreshStateRecovering;
            [_footer.view scrollView:_scrollView willEndRefreshing:NO];
            
            [self setNeedsLayoutFooterRefreshView];
            [self layoutFooterRefreshViewIfNeeded];
            
            _footer.state = XZRefreshStatePendinging;
            [_footer.view scrollView:_scrollView didEndRefreshing:NO];
            XZRefreshAsync(completion, NO);
        } else {
            _footer.state = XZRefreshStateRecovering;
            [_footer.view scrollView:_scrollView willEndRefreshing:animated];
            
            XZRefreshAnimate(animated, ^{
                [self setNeedsLayoutFooterRefreshView];
                [self layoutFooterRefreshViewIfNeeded];
                
                if (_footer.contentOffsetY < contentOffset.y) {
                    _scrollView.contentOffset = CGPointMake(contentOffset.x, _footer.contentOffsetY);
                }
            }, ^(BOOL finished) {
                _footer.state = XZRefreshStatePendinging;
                [_footer.view scrollView:_scrollView didEndRefreshing:animated];
                XZRefreshAsync(completion, finished);
            });
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return;
    }
    
    if (_header.state != XZRefreshStatePendinging) {
        return;
    }

    if (_footer.state != XZRefreshStatePendinging) {
        if (_footer.needsAnimatedTransitioning) {
            CGRect  const bounds = _scrollView.bounds;
            CGFloat const newY   = _scrollView.contentOffset.y + bounds.size.height - _footer.height + _footer.offset;
            CGRect newFrame = _footer.view.frame;
            if (newY <= _footer.frame.origin.y) {
                _footer.view.frame = _footer.frame;
                _footer.needsAnimatedTransitioning = NO;
            } else if (newY < newFrame.origin.y) {
                newFrame.origin.y = newY;
                _footer.view.frame = newFrame;
            }
        }
        return;
    }
    
    CGPoint const contentOffset = _scrollView.contentOffset;
    
    if (contentOffset.y < _header.contentOffsetY) {
        // 进入了下拉刷新的区域
        
        // 如果上一个状态是上拉加载，通知 footer 上拉已经结束了。
        if (_distance > 0) {
            [_footer.view scrollView:_scrollView didScrollRefreshing:0];
        }
        
        // 计算滚动距离
        _distance = contentOffset.y - _header.contentOffsetY;
        
        // 通知刷新视图
        [_header.view scrollView:_scrollView didScrollRefreshing:-_distance];
    } else if (contentOffset.y > _footer.contentOffsetY) {
        // 进入了上拉加载的区域
        
        // 如果上一个状态是上拉加载，通知 header 下拉已经结束了。
        if (_distance < 0) {
            [_header.view scrollView:_scrollView didScrollRefreshing:0];
        }
        
        // 上拉距离
        _distance = contentOffset.y - _footer.contentOffsetY;
        
        // 通知刷新视图
        [_footer.view scrollView:_scrollView didScrollRefreshing:_distance];
    } else if (_header.isAutomatic && contentOffset.y - _header.contentOffsetY <= _header.automaticRefreshDistance) {
        _header.isAutomatic = NO;
        [self _beginHeaderRefreshingAtContentOffset:NULL];
    } else if (_footer.isAutomatic && _footer.contentOffsetY - contentOffset.y <= _footer.automaticRefreshDistance) {
        _footer.isAutomatic = NO;
        [self _beginFooterRefreshingAtContentOffset:NULL];
    } else {
        // 未在下拉或上拉区域，归零刷新状态
        if (_distance < 0) {
            _distance = 0;
            [_header.view scrollView:_scrollView didScrollRefreshing:0];
        } else if (_distance > 0) {
            _distance = 0;
            [_footer.view scrollView:_scrollView didScrollRefreshing:0];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)_scrollView {
    if (_scrollView != self->_scrollView) {
        return;
    }
    if (_header.view.automaticRefreshDistance > 0) {
        CGFloat const y = _scrollView.contentOffset.y;
        _header.automaticRefreshDistance = _header.view.automaticRefreshDistance;
        _header.isAutomatic = (y - _header.contentOffsetY > _header.automaticRefreshDistance);
    } else {
        _header.isAutomatic = NO;
    }
    if (_footer.view.automaticRefreshDistance > 0) {
        CGFloat const y = _scrollView.contentOffset.y;
        _footer.automaticRefreshDistance = _footer.view.automaticRefreshDistance;
        _footer.isAutomatic = (_footer.contentOffsetY - y > _footer.automaticRefreshDistance);
    } else {
        _footer.isAutomatic = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView * const)_scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_scrollView != self->_scrollView) {
        return;
    }
    
    XZRefreshContext * const _header = self->_header;
    
    switch (_header.state) {
        case XZRefreshStatePendinging: {
            if (_distance < 0) {
                if ([_header.view scrollView:_scrollView shouldBeginRefreshing:-_distance]) {
                    [self _beginHeaderRefreshingAtContentOffset:targetContentOffset];
                }
                return;
            }
            break;
        }
        case XZRefreshStateWillRefreshing: {
            _header.state = XZRefreshStateRefreshing;
            
            CGPoint const contentOffset = _scrollView.contentOffset;
            _scrollView.contentInset  = XZRefreshAddTop(_scrollView.contentInset, _header.height);
            _scrollView.verticalScrollIndicatorInsets = XZRefreshAddTop(_scrollView.verticalScrollIndicatorInsets, _header.height);
            _scrollView.contentOffset = contentOffset;
            
            [self setNeedsLayoutHeaderRefreshView];
            [self layoutHeaderRefreshViewIfNeeded];
            
            targetContentOffset->y = _header.contentOffsetY;
            return;
        }
        case XZRefreshStateWillRecovering: {
            UIScrollView     * const _scrollView   = self->_scrollView;
            XZRefreshContext * const _header       = self->_header;
            CGPoint            const contentOffset = _scrollView.contentOffset;
            
            _scrollView.contentInset = XZRefreshAddTop(_scrollView.contentInset, -_header.height);
            _scrollView.verticalScrollIndicatorInsets = XZRefreshAddTop(_scrollView.verticalScrollIndicatorInsets, -_header.height);
            _scrollView.contentOffset = contentOffset;
            
            _header.state = XZRefreshStateRecovering;
            [self setNeedsLayoutHeaderRefreshView];
            [self layoutHeaderRefreshViewIfNeeded];
            
            if (contentOffset.y < _header.contentOffsetY) {
                targetContentOffset->y = _header.contentOffsetY;
            }
            return;
        }
        default:
            break;
    }
    
    XZRefreshContext * const _footer = self->_footer;
    
    switch (_footer.state) {
        case XZRefreshStatePendinging: {
            if (_distance > 0) {
                if ([_footer.view scrollView:_scrollView shouldBeginRefreshing:+_distance]) {
                    [self _beginFooterRefreshingAtContentOffset:targetContentOffset];
                }
                return;
            }
            break;
        }
        case XZRefreshStateWillRefreshing: {
            _footer.state = XZRefreshStateRefreshing;
            
            CGPoint const contentOffset = _scrollView.contentOffset;
            _scrollView.contentInset = XZRefreshAddBottom(_scrollView.contentInset, _footer.height);
            _scrollView.verticalScrollIndicatorInsets = XZRefreshAddBottom(_scrollView.verticalScrollIndicatorInsets, _footer.height);
            _scrollView.contentOffset = contentOffset;
            
            [self setNeedsLayoutFooterRefreshView];
            [self layoutFooterRefreshViewIfNeeded];
            
            targetContentOffset->y = _footer.contentOffsetY;
            return;
        }
        case XZRefreshStateWillRecovering: {
            UIScrollView     * const _scrollView   = self->_scrollView;
            XZRefreshContext * const _footer       = self->_footer;
            CGPoint            const contentOffset = _scrollView.contentOffset;
            
            // 恢复边距
            _scrollView.contentInset = XZRefreshAddBottom(_scrollView.contentInset, -_footer.height);
            _scrollView.verticalScrollIndicatorInsets = XZRefreshAddBottom(_scrollView.verticalScrollIndicatorInsets, -_footer.height);
            _scrollView.contentOffset = contentOffset;
            
            _footer.state = XZRefreshStateRecovering;
            [self setNeedsLayoutFooterRefreshView];
            [self layoutFooterRefreshViewIfNeeded];
            
            if (contentOffset.y > _footer.contentOffsetY) {
                targetContentOffset->y = _footer.contentOffsetY;
            }
            return;
        }
        default: {
            break;
        }
    }
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        return;
    }
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return;
    }
    
    switch (_header.state) {
        case XZRefreshStateRecovering:
            _header.state = XZRefreshStatePendinging;
            [_header.view scrollView:scrollView didEndRefreshing:YES];
            return;
            
        default:
            break;
    }
    
    switch (_footer.state) {
        case XZRefreshStateRecovering:
            _footer.state = XZRefreshStatePendinging;
            [_footer.view scrollView:scrollView didEndRefreshing:YES];
            break;
            
        default:
            break;
    }
}

- (void)_beginHeaderRefreshingAtContentOffset:(inout CGPoint * _Nullable)targetContentOffset {
    UIScrollView *     const _scrollView   = self->_scrollView;
    XZRefreshContext * const _header       = self->_header;
    CGPoint            const contentOffset = _scrollView.contentOffset;
    
    _distance = 0;
    _header.state = XZRefreshStateRefreshing;
    
    // 增加到 contentInset 的边距会叠加到 adjustedContentInset 中
    // 改变 contentInset 会触发 didScroll 方法，可能改变 contentOffset
    _scrollView.contentInset  = XZRefreshAddTop(_scrollView.contentInset, _header.height);
    _scrollView.verticalScrollIndicatorInsets = XZRefreshAddTop(_scrollView.verticalScrollIndicatorInsets, _header.height);
    _scrollView.contentOffset = contentOffset;
    
    [self setNeedsLayoutHeaderRefreshView];
    [self layoutHeaderRefreshViewIfNeeded];
    
    if (targetContentOffset) {
        targetContentOffset->y = _header.contentOffsetY;
    }
    
    [_header.view scrollView:_scrollView didBeginRefreshing:NO];
    // [_header.view sendActionsForControlEvents:(UIControlEventValueChanged)];
    
    id<XZRefreshDelegate> const delegate = _header.view.delegate ?: (id)_scrollView.delegate;
    if ([delegate respondsToSelector:@selector(scrollView:headerDidBeginRefreshing:)]) {
        [delegate scrollView:_scrollView headerDidBeginRefreshing:_header.view];
    }
}

- (void)_beginFooterRefreshingAtContentOffset:(inout CGPoint * _Nullable)targetContentOffset {
    XZRefreshContext * const _footer       = self->_footer;
    UIScrollView *     const _scrollView   = self->_scrollView;
    CGPoint            const contentOffset = _scrollView.contentOffset;
    
    _distance = 0;
    _footer.state = XZRefreshStateRefreshing;
    
    _scrollView.contentInset = XZRefreshAddBottom(_scrollView.contentInset, _footer.height);
    _scrollView.verticalScrollIndicatorInsets = XZRefreshAddBottom(_scrollView.verticalScrollIndicatorInsets, _footer.height);
    _scrollView.contentOffset = contentOffset;

    CGRect const oldFrame = _footer.view.frame;
    [self setNeedsLayoutFooterRefreshView];
    [self layoutFooterRefreshViewIfNeeded];
    
    // 回弹的目标位置
    if (targetContentOffset) {
        targetContentOffset->y = _footer.contentOffsetY;
    }
    
    if (_footer.needsAnimatedTransitioning) {
        _footer.view.frame = oldFrame;
    }

    [_footer.view scrollView:_scrollView didBeginRefreshing:NO];
    // [_footer.view sendActionsForControlEvents:(UIControlEventValueChanged)];
    
    id<XZRefreshDelegate> const delegate = _footer.view.delegate ?: (id)_scrollView.delegate;
    if ([delegate respondsToSelector:@selector(scrollView:footerDidBeginRefreshing:)]) {
        [delegate scrollView:_scrollView footerDidBeginRefreshing:_footer.view];
    }
}

@end

#import <objc/runtime.h>

// Association keys.
static const void * const _manager = &_manager;

@implementation UIScrollView (XZRefreshManager)

+ (void)load {
    Class const aCls = UIScrollView.class;
    if (self == aCls && [self instancesRespondToSelector:@selector(adjustedContentInsetDidChange)]) {
        Method const oldMethod = class_getInstanceMethod(aCls, @selector(adjustedContentInsetDidChange));
        Method const newMethod = class_getInstanceMethod(aCls, @selector(__xz_refresh_exchange_adjustedContentInsetDidChange));
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

- (XZRefreshManager *)xz_refreshManager {
    XZRefreshManager *refreshingManager = objc_getAssociatedObject(self, _manager);
    if (refreshingManager != nil) {
        return refreshingManager;
    }
    refreshingManager = [[XZRefreshManager alloc] initWithScrollView:self];
    objc_setAssociatedObject(self, _manager, refreshingManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return refreshingManager;
}

- (XZRefreshManager *)xz_refreshManagerIfLoaded {
    return objc_getAssociatedObject(self, _manager);
}

- (void)__xz_refresh_exchange_adjustedContentInsetDidChange {
    [self __xz_refresh_exchange_adjustedContentInsetDidChange];
    
    [self.xz_refreshManagerIfLoaded setNeedsLayoutRefreshViews];
}

@end





/// 获取类 aClass 自身的实例方法，不包括从父类继承的方法。
static Method XZClassGetInstanceMethod(Class const aClass, SEL const selector) {
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

static BOOL XZRefreshAddMethod(Class const aClass, SEL const selector, Class source, SEL const selectorForOverride, SEL const selectorForExchange, const void * const _key) {
    if (objc_getAssociatedObject(aClass, _key)) return NO;
    
    // 方法已实现
    if ([aClass instancesRespondToSelector:selector]) {
        Method const oldMethod = XZClassGetInstanceMethod(aClass, selector);
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

#pragma mark - ScrollView delegate

@implementation XZRefreshScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end

@implementation XZRefreshPlaceholderDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidScroll:scrollView];
}

- (void)__xz_refresh_override_scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidScroll:scrollView];
    [super scrollViewDidScroll:scrollView];
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
    [super scrollViewWillBeginDragging:scrollView];
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
    [super scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
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
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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
    [super scrollViewDidEndDecelerating:scrollView];
}

- (void)__xz_refresh_exchange_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView.xz_refreshManagerIfLoaded scrollViewDidEndDecelerating:scrollView];
    [self __xz_refresh_exchange_scrollViewDidEndDecelerating:scrollView];
}

@end

