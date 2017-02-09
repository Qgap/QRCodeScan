//
//  ScanResultViewController.m
//  QRCode
//
//  Created by gap on 17/2/8.
//  Copyright © 2017年 gap. All rights reserved.
//

#import "ScanResultViewController.h"
#import <Masonry.h>

const CGFloat gap = 15;

@interface ScanResultViewController ()

@property (nonatomic,strong) UILabel *resultLabel;

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描结果";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.resultLabel.textColor = [UIColor blackColor];
    self.resultLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.resultLabel];
    self.resultLabel.text = self.resultString;
    UIEdgeInsets padding = UIEdgeInsetsMake(gap, gap, -gap, -gap);
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(self.view.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(self.view.mas_right).with.offset(padding.right);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableArray *viewControllers = [[NSMutableArray arrayWithArray:self.navigationController.viewControllers] mutableCopy];
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"ScanQRViewController")]) {
            [viewControllers removeObject:obj];
        }
    }];
    
    self.navigationController.viewControllers = viewControllers;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
