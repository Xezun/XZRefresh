//
//  XZRefreshStyle1View.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "XZRefreshStyle1View.h"
#import "UIScrollView+XZRefresh.h"
#import "XZRefreshDefines.h"

#define XZRefreshStyle1AnimationDuration  4.0
#define XZRefreshStyle1TrackColor         [UIColor colorWithWhite:0.90 alpha:1.0]

@implementation XZRefreshStyle1View {
    UIView *_view;
    CAShapeLayer *_trackLayer;
    CAShapeLayer *_shapeLayer;
}

@synthesize color = _color;
@synthesize trackColor = _trackColor;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self XZRefreshDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZRefreshDidInitialize];
    }
    return self;
}

- (void)XZRefreshDidInitialize {
    CGRect  const bounds = self.bounds;
    CGFloat const x = CGRectGetMidX(bounds) - 15.0;
    CGFloat const y = CGRectGetMidY(bounds) - 15.0;
    CGRect  const frame = CGRectMake(x, y, 30.0, 30.0);
    
    _view = [[UIView alloc] initWithFrame:frame];
    _view.userInteractionEnabled = NO;
    _view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_view];
    
    _trackLayer = [[CAShapeLayer alloc] init];
    _trackLayer.frame = CGRectMake(0, 0, 30, 30);
    _trackLayer.lineWidth = 3.0;
    _trackLayer.strokeColor = XZRefreshStyle1TrackColor.CGColor;
    _trackLayer.fillColor   = UIColor.clearColor.CGColor;
    _trackLayer.strokeStart = 0;
    _trackLayer.strokeEnd   = 1.0;
    _trackLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(5.0, 5.0, 20.0, 20.0)].CGPath;
    [_view.layer addSublayer:_trackLayer];
    
    _shapeLayer = [[CAShapeLayer alloc] init];
    _shapeLayer.frame = CGRectMake(0, 0, 30, 30);
    _shapeLayer.lineWidth = 3.0;
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.strokeColor = self.tintColor.CGColor;
    _shapeLayer.fillColor   = UIColor.clearColor.CGColor;
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 1.0;
    _shapeLayer.repeatCount = FLT_MAX;
    _shapeLayer.autoreverses = YES;
    // _shapeLayer.duration = 4.0; // 设置了 duration 就不显示 ？？
    [_view.layer addSublayer:_shapeLayer];
    
    // 路径：弧度为 5 * 2π 的圆弧
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(15.0, 5.0)];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    _shapeLayer.path = path.CGPath;
    
    // 初始状态：展示 1 / 4 进度的圆弧，无限小
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 0;
    _trackLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
    _shapeLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    if (_color == nil) {
        _shapeLayer.strokeColor = self.tintColor.CGColor;
    }
}

- (UIColor *)color {
    return _color ?: self.tintColor;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _shapeLayer.strokeColor = self.color.CGColor;
}

- (UIColor *)trackColor {
    return _trackColor ?: XZRefreshStyle1TrackColor;
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    _trackLayer.strokeColor = self.trackColor.CGColor;
}

- (void)scrollView:(UIScrollView *)scrollView didScrollRefreshing:(CGFloat)distance {
    // NSLog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat const RefreshHeight = self.height;
    CGFloat const PullHeight    = RefreshHeight * 1.5; // 进入下拉刷新的高度为刷新高度的 1.5 倍
    CGFloat const ViewHeight_2  = self.frame.size.height * 0.5;
    
    // 大部分情况下，刷新视图位于屏幕外，或者导航条之下，所以在刷新视图漏出一半之前，动画实际是不可见的，
    // 因此，展示动画的环，从刷新视图漏出一半开始入场。
    if (distance <= ViewHeight_2) {
        // 等待进场：圆弧无限小，不可见
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 0;
        _trackLayer.transform   = CATransform3DMakeScale(0, 0, 1.0);
        _shapeLayer.transform   = CATransform3DMakeScale(0, 0, 1.0);
    } else {
        CGFloat const transition = (distance - ViewHeight_2) / (PullHeight - ViewHeight_2);
        if (transition < 0.5) {
            // 变大进场：圆弧开始增长，并从小变大
            _shapeLayer.strokeStart = 0;
            _shapeLayer.strokeEnd   = 3.0 * transition / 15.0; // 0.34 * (1.5 - value);
            _trackLayer.transform   = CATransform3DMakeScale(transition * 2.0, transition * 2.0, 1.0);
            _shapeLayer.transform   = CATransform3DMakeScale(transition * 2.0, transition * 2.0, 1.0);
        } else if (transition < 1.0) {
            // 蓄力刷新：圆弧增长 1.0，大小恢复正常。
            // 由于线端 cap 的原因，圆弧进度在略小于 1.0 的时候，显示效果就已经为闭合状态，
            // 因此减 0.2 以保证在进度未满时，圆弧必须处于未闭合状态，而用户看到闭合的圆环时，松手一定可以进入刷新状态。
            _shapeLayer.strokeStart = 0;
            _shapeLayer.strokeEnd   = MIN(transition * 3.0 / 15.0, (3.0 - 0.2) / 15.0);
            _trackLayer.transform   = CATransform3DIdentity;
            _shapeLayer.transform   = CATransform3DIdentity;
        } else {
            // 等待刷新
            _shapeLayer.strokeStart = 0;
            _shapeLayer.strokeEnd   = 3.0 / 15.0;
            _trackLayer.transform   = CATransform3DIdentity;
            _shapeLayer.transform   = CATransform3DIdentity;
        }
    }
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    // NSLog(@"%s", __PRETTY_FUNCTION__);
    return (distance >= self.height * 1.5);
}

- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated {
    // NSLog(@"%s", __PRETTY_FUNCTION__);
    _trackLayer.transform = CATransform3DIdentity;
    _shapeLayer.transform = CATransform3DIdentity;
    
    // 将动画效果延时到进场动画之后
    CFTimeInterval beginTime = 0;
    
    // 直接触发刷新时，由于没有进场过程，因此需要添加动画效果模拟进场。
    if (animated) {
        beginTime = [_shapeLayer convertTime:CACurrentMediaTime() toLayer:nil] + XZRefreshAnimationDuration;
        
        // 直接进场时，动画的距离与下拉时的动画距离并不相同，因此动画效果为满圆进场。
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 3.0 / 15.0;
        [CATransaction commit];
        
        // iOS 16.2: transform 的隐式动画时长不受控制，因此用了 CAAnimation 处理缩放效果。
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.values = @[
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshAnimationDuration;
        animation.removedOnCompletion = YES;
        [_trackLayer addAnimation:animation forKey:@"entering"];
        [_shapeLayer addAnimation:animation forKey:@"entering"];
    }
    
    // 自定义个动画曲线，以实现运动速度平滑过渡：
    // 运动速度，由于时间是均匀的，根据距离可知，最快速度为 3.0 / 15.0，最慢速度为 1.0 / 15.0，
    // 所以，3.0 / 15.0 的速度阶段，应该从 1.0 / 15.0 加速，并最后减速到 1.0 / 15.0，
    // 切线的斜率在或结束时都应该为 1 / 3 ，且在开始收缩或开始拉伸时，加速应该是最快的。
    CAMediaTimingFunction *easeio = [CAMediaTimingFunction functionWithControlPoints:0.15 :0.05 :0.7 :0.9];
    CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // strokeStart 快速时，收缩进度
    CAKeyframeAnimation *an1 = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    an1.values = @[
        @(0/15.0), @(3.0/15.0), @(4.0/15.0), @(7.0/15.0), @(8.0/15.0), @(11.0/15.0), @(12.0/15.0),
    ];
    an1.timingFunctions = @[easeio, linear, easeio, linear, easeio, linear];
    
    // strokeEnd 快速时，拉伸进度
    CAKeyframeAnimation *an2 = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    an2.values = @[
        @(2.8/15.0), @(4.0/15.0), @(6.8/15.0), @(8.0/15.0), @(10.8/15.0), @(12.0/15.0), @(14.8/15.0),
    ];
    an2.timingFunctions = @[linear, easeio, linear, easeio, linear, easeio];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations  = @[an1, an2];
    group.beginTime   = beginTime;
    group.duration    = XZRefreshStyle1AnimationDuration;
    group.repeatCount = FLT_MAX;
    group.removedOnCompletion = NO;
    [_shapeLayer addAnimation:group forKey:@"refreshing"];
}

- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated {
    // NSLog(@"%s", __PRETTY_FUNCTION__);
    CGFloat const start = _shapeLayer.presentationLayer.strokeStart;
    CGFloat const end   = _shapeLayer.presentationLayer.strokeEnd;
    [_shapeLayer removeAnimationForKey:@"refreshing"];
    
    if (animated) {
        // 退场准备：拷贝末尾进度
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _shapeLayer.strokeStart = start;
        _shapeLayer.strokeEnd   = end;
        [CATransaction commit];
        
        // 退场动画：圆圈变小
        CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation2.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DMakeScale(0.0, 0.0, 1.0)),
            @(CATransform3DMakeScale(0.0, 0.0, 1.0))
        ];
        animation2.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation2.duration = XZRefreshAnimationDuration;
        animation2.removedOnCompletion = NO;
        animation2.fillMode = kCAFillModeBoth;
        [_trackLayer addAnimation:animation2 forKey:@"recovering.transform"];
        [_shapeLayer addAnimation:animation2 forKey:@"recovering.transform"];
    } else {
        // 不需要动画时，直接执行 didEndRefreshing 的收尾过程即可。
    }
}

- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated {
    [_shapeLayer removeAnimationForKey:@"recovering.strokeEnd"];
    [_trackLayer removeAnimationForKey:@"recovering.transform"];
    [_shapeLayer removeAnimationForKey:@"recovering.transform"];
    
    // NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 0;
    _trackLayer.transform   = CATransform3DMakeScale(0.0, 0.0, 1.0);
    _shapeLayer.transform   = CATransform3DMakeScale(0.0, 0.0, 1.0);
    [CATransaction commit];
}

@end
