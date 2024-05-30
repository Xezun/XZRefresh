//
//  ExampleSettingsViewController.m
//  Example
//
//  Created by Xezun on 2023/8/15.
//

#import "ExampleSettingsViewController.h"
#import "ExampleRefreshSettingsViewController.h"

@interface ExampleSettingsViewController ()

@end

@implementation ExampleSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if (identifier.length == 0) {
        return;
    }
    
    ExampleRefreshSettingsViewController *vc = segue.destinationViewController;
    if ([identifier isEqualToString:@"Header"]) {
        vc.title = @"下拉刷新";
        vc.refreshView = self.headerRefreshView;
    } else if ([identifier isEqualToString:@"Footer"]) {
        vc.title = @"上拉加载";
        vc.refreshView = self.footerRefreshView;
    }
}

@end



