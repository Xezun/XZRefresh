//
//  TestScrollEventsViewController.m
//  Example
//
//  Created by Xezun on 2023/8/30.
//

#import "TestScrollEventsViewController.h"

// 测试结果1:
// 在减速滚动的过程中，再次拖拽，减速过程被中断，但是不会触发 -scrollViewDidEndDecelerating: 方法。

@interface TestScrollEventsViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;

@end

@implementation TestScrollEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)navResetButtonAction:(id)sender {
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

- (IBAction)navPlusButtonAction:(id)sender {
    self.constraint.constant += 10;
}

- (IBAction)navLessButtonAction:(id)sender {
    self.constraint.constant -= 10;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
