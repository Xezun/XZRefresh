//
//  TestStyle2ViewController.m
//  Example
//
//  Created by 徐臻 on 2024/5/30.
//

#import "TestStyle2ViewController.h"
@import XZRefresh;

@interface TestStyle2ViewController ()
@property (weak, nonatomic) IBOutlet XZRefreshView *refreshView;
@end

@implementation TestStyle2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITableView *tableView;
    [self.refreshView scrollView:tableView didBeginRefreshing:YES];
}

@end
