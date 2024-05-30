//
//  AnimationStyle2ViewController.m
//  Example
//
//  Created by 徐臻 on 2024/5/30.
//

#import "AnimationStyle2ViewController.h"
@import XZShapeView;

#define kAnimationDuration 20.0

@interface AnimationStyle2ViewController ()
@property (weak, nonatomic) IBOutlet XZShapeView *shapeView;
@end

@implementation AnimationStyle2ViewController

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
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(75, 5)];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(75.0, 75.0) radius:70.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    _shapeLayer.path = path.CGPath;
    
    CAKeyframeAnimation *an1 = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    an1.values = @[
        @(0.0/16.0), @(1.0/16.0), @(3.0/16.0), @(4.0/16.0), @(6.0/16.0), @(7.0/16.0), @(9.0/16.0), @(10.0/16.0), @(12.0/16.0)
    ];
    //an1.keyTimes = @[@(0.0), @(1.0/12.0), @(3.0/12.0), @(4.0/12.0), @(6.0/12.0), @(7.0/12.0), @(9.0/12.0), @(10.0/12.0), @(12.0/12.0)];
    an1.duration = kAnimationDuration;
    an1.repeatCount = FLT_MAX;
    an1.removedOnCompletion = NO;
    [_shapeLayer addAnimation:an1 forKey:@"refreshing.strokeStart"];

    CAKeyframeAnimation *an2 = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    an2.values = @[
        @(1.0/16.0), @(3.0/16.0), @(4.0/16.0), @(6.0/16.0), @(7.0/16.0), @(9.0/ 16.0), @(10.0/16.0), @(12.0/16.0), @(13.0/16.0)
    ];
    //an2.keyTimes = @[@(0.0), @(1.0/12.0), @(3.0/12.0), @(4.0/12.0), @(6.0/12.0), @(7.0/12.0), @(9.0/12.0), @(10.0/12.0), @(12.0/12.0)];
    an2.duration = kAnimationDuration;
    an2.repeatCount = FLT_MAX;
    an2.removedOnCompletion = NO;
    [_shapeLayer addAnimation:an2 forKey:@"refreshing.strokeEnd"];
}

@end
