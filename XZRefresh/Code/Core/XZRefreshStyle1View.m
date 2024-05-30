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

#define XZRefreshStyle1AnimationDuration  3.0
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
    
    // 路径：弧度为 4 * 2π 的圆弧
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(15.0, 5.0)];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    _shapeLayer.path = path.CGPath;
    
    // 初始状态：展示 1 / 4 进度的圆弧，无限小
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 1.0 / 16.0;
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
    CGFloat const p = distance / self.height;
    
    if (p <= 0.5) {
        // 等待进场：圆弧进度为 0.25，无限小，不可见
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = p / 16.0;
        _trackLayer.transform   = CATransform3DMakeScale(0, 0, 1.0);
        _shapeLayer.transform   = CATransform3DMakeScale(0, 0, 1.0);
    } else if (p < 1.0) {
        // 变大进场：圆弧开始增长 0.25 - 1.0，并从无限小变大
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = p / 16.0; // 0.34 * (1.5 - value);
        _trackLayer.transform   = CATransform3DMakeScale((p - 0.5) * 2.0, (p - 0.5) * 2.0, 1.0);
        _shapeLayer.transform   = CATransform3DMakeScale((p - 0.5) * 2.0, (p - 0.5) * 2.0, 1.0);
    } else if (p < 1.5) {
        // 蓄力刷新：圆弧增长 1.0，大小恢复正常。
        // 由于线端 cap 的原因，圆弧进度在略小于 1.0 的时候，显示效果就已经为闭合状态，
        // 因此减 0.2 以保证用户看到圆弧闭合时，松手可以进入刷新状态。
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = MIN(1.0 / 16.0 + (4.0 / 16.0 - 1.0 / 16.0) * (p - 1.0) * 2.0, (4.0 - 0.2) / 16.0);
        _trackLayer.transform   = CATransform3DIdentity;
        _shapeLayer.transform   = CATransform3DIdentity;
    } else {
        // 等待刷新
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 4.0 / 16.0;
        _trackLayer.transform   = CATransform3DIdentity;
        _shapeLayer.transform   = CATransform3DIdentity;
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
        _shapeLayer.strokeEnd   = 4.0 / 16.0;
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
    
    CAKeyframeAnimation *an1 = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    an1.values = @[
        @(0/16.0), @(4.8/16.0), @(6.0/16.0), @(10.8/16.0), @(12.0/16.0),
    ];
    CAKeyframeAnimation *an2 = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    an2.values = @[
        @(4.0/16.0), @(5.0/16.0), @(9.8/16.0), @(11.0/16.0), @(15.8/16.0)
    ];
    
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
    _shapeLayer.strokeEnd   = 1.0 / 16.0;
    _trackLayer.transform   = CATransform3DMakeScale(0.0, 0.0, 1.0);
    _shapeLayer.transform   = CATransform3DMakeScale(0.0, 0.0, 1.0);
    [CATransaction commit];
}

@end
