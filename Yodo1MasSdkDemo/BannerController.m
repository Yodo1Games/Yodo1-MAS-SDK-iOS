//
//  BannerController.m
//  Yodo1MasSdkDemo
//
//  Created by 周玉震 on 2021/3/23.
//

#import "BannerController.h"
#import <Yodo1MasCore/Yodo1Mas.h>

@interface BannerController ()

@end

@implementation BannerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *back = [[UIButton alloc] init];
    [back addTarget:self action:@selector(onBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    back.frame = CGRectMake(100, 200, 100, 30);
    [self.view addSubview:back];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Yodo1Mas sharedInstance] showBannerAd];
}

- (void)onBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
