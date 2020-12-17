//
//  DemoViewController.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "DemoViewController.h"
#import <Yodo1MasCore/Yodo1Mas.h>

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *gdprSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coppaSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ccpaSwitch;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)onRewardClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showRewardAdvert:self callback:^(Yodo1MasAdvertEvent *event) {

    }];
}

- (IBAction)onInterstitialClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showInterstitialAdvert:self callback:^(Yodo1MasAdvertEvent *event) {

    }];
}

- (IBAction)onBannerClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showBannerAdvert:self callback:^(Yodo1MasAdvertEvent *event) {

    }];
}

- (IBAction)onGDPRChanged:(UISwitch *)sender {
    
}

- (IBAction)onCOPPAChanged:(UISwitch *)sender {
    
}

- (IBAction)onCCPAChanged:(UISwitch *)sender {
    
}


@end
