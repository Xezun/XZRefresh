//
//  AnimationStyle1ViewController.m
//  Example
//
//  Created by 徐臻 on 2024/5/30.
//

#import "AnimationStyle1ViewController.h"
@import XZShapeView;

#define kAnimationDuration 10.0

@interface AnimationStyle1ViewController ()
@property (weak, nonatomic) IBOutlet XZShapeView *shapeView;
@end

@implementation AnimationStyle1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGray5Color;
    
    CAShapeLayer *_shapeLayer = self.shapeView.layer;
    _shapeLayer.frame = CGRectMake(100, 100, 100, 100);
    _shapeLayer.path = nil;
    _shapeLayer.lineWidth = 5.0;
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.strokeColor = UIColor.redColor.CGColor;
    _shapeLayer.backgroundColor = UIColor.whiteColor.CGColor;
    _shapeLayer.fillColor = UIColor.clearColor.CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CAShapeLayer *_shapeLayer = self.shapeView.layer;
    [_shapeLayer removeAllAnimations];

    CAMediaTimingFunction *easeio = [CAMediaTimingFunction functionWithControlPoints:0.15 :0.05 :0.7 :0.9];
    CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(75, 5)];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    _shapeLayer.path = path.CGPath;
    
    CAKeyframeAnimation *an1 = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    an1.values = @[
        @(0/15.0), @(3.0/15.0), @(4.0/15.0), @(7.0/15.0), @(8.0/15.0), @(11.0/15.0), @(12.0/15.0),
    ];
    an1.timingFunctions = @[easeio, linear, easeio, linear, easeio, linear];
    an1.duration = kAnimationDuration;
    an1.repeatCount = FLT_MAX;
    an1.removedOnCompletion = NO;
    [_shapeLayer addAnimation:an1 forKey:@"refreshing.strokeStart"];

    CAKeyframeAnimation *an2 = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    an2.values = @[
        @(2.8/15.0), @(4.0/15.0), @(6.8/15.0), @(8.0/15.0), @(10.8/15.0), @(12.0/15.0), @(14.8/15.0),
    ];
    an2.timingFunctions = @[linear, easeio, linear, easeio, linear, easeio];
    an2.duration = kAnimationDuration;
    an2.repeatCount = FLT_MAX;
    an2.removedOnCompletion = NO;
    [_shapeLayer addAnimation:an2 forKey:@"refreshing.strokeEnd"];
    
    CAKeyframeAnimation *an3 = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    an3.values = @[
        (__bridge id)UIColor.redColor.CGColor,
        (__bridge id)UIColor.blueColor.CGColor,
        (__bridge id)UIColor.greenColor.CGColor,
        (__bridge id)UIColor.orangeColor.CGColor,
        (__bridge id)UIColor.cyanColor.CGColor,
        (__bridge id)UIColor.purpleColor.CGColor,
        (__bridge id)UIColor.redColor.CGColor,
    ];
    an3.duration = kAnimationDuration;
    an3.repeatCount = FLT_MAX;
    an3.removedOnCompletion = NO;
    [_shapeLayer addAnimation:an3 forKey:@"refreshing.strokeColor"];
}

@end
