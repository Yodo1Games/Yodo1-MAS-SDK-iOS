//
//  DemoViewController.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "DemoViewController.h"
#import <Yodo1MasCore/Yodo1Mas.h>
#import <Toast/Toast.h>

@interface DemoViewController ()<Yodo1MasRewardAdvertDelegate, Yodo1MasInterstitialAdvertDelegate, Yodo1MasBannerAdvertDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *gdprSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coppaSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ccpaSwitch;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _gdprSwitch.on = [Yodo1Mas sharedInstance].isGDPRUserConsent;
    _coppaSwitch.on = [Yodo1Mas sharedInstance].isCOPPAAgeRestricted;
    _ccpaSwitch.on = [Yodo1Mas sharedInstance].isCCPADoNotSell;
    [Yodo1Mas sharedInstance].rewardAdvertDelegate = self;
    [Yodo1Mas sharedInstance].interstitialAdvertDelegate = self;
    [Yodo1Mas sharedInstance].bannerAdvertDelegate = self;
}

- (IBAction)onRewardClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showRewardAdvert];
}

- (IBAction)onInterstitialClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showInterstitialAdvert];
}

- (IBAction)onBannerClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showBannerAdvert];
}

- (IBAction)onGDPRChanged:(UISwitch *)sender {
    [Yodo1Mas sharedInstance].isGDPRUserConsent = sender.isOn;
}

- (IBAction)onCOPPAChanged:(UISwitch *)sender {
    [Yodo1Mas sharedInstance].isCOPPAAgeRestricted = sender.isOn;
}

- (IBAction)onCCPAChanged:(UISwitch *)sender {
    [Yodo1Mas sharedInstance].isCCPADoNotSell = sender.isOn;
}

#pragma mark - Yodo1MasAdvertDelegate
- (void)onAdvertOpened:(Yodo1MasAdvertEvent *)event {
    
}

- (void)onAdvertClosed:(Yodo1MasAdvertEvent *)event {
    
}

- (void)onAdvertError:(Yodo1MasAdvertEvent *)event error:(Yodo1MasError *)error {
    [self.view makeToast:error.userInfo[NSLocalizedDescriptionKey]];
}

#pragma mark - Yodo1MasRewardAdvertDelegate
- (void)onAdvertRewardEarned:(Yodo1MasAdvertEvent *)event {
    
}

@end
