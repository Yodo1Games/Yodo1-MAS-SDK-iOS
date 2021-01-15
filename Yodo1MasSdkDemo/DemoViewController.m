//
//  DemoViewController.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "DemoViewController.h"
#import <Yodo1MasCore/Yodo1Mas.h>
#import <Toast/Toast.h>
#import <AppLovinSDK/AppLovinSDK.h>
//@import GoogleMobileAdsMediationTestSuite;

@interface DemoViewController ()<Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate>

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
    [Yodo1Mas sharedInstance].rewardAdDelegate = self;
    [Yodo1Mas sharedInstance].interstitialAdDelegate = self;
    [Yodo1Mas sharedInstance].bannerAdDelegate = self;
}

- (IBAction)onRewardClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showRewardAd];
}

- (IBAction)onInterstitialClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showInterstitialAd];
}

- (IBAction)onBannerClicked:(UIButton *)sender {
    [[Yodo1Mas sharedInstance] showBannerAd];
}

- (IBAction)onAdMobMediationTestClicked:(UIButton *)sender {
    //[GoogleMobileAdsMediationTestSuite presentForAdManagerOnViewController:self delegate:nil];
}

- (IBAction)onAppLovinMediationDebuggerClicked:(UIButton *)sender {
    [[ALSdk shared] showMediationDebugger];
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

#pragma mark - Yodo1MasAdDelegate
- (void)onAdOpened:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    [self.view makeToast:error.userInfo[NSLocalizedDescriptionKey]];
}

#pragma mark - Yodo1MasRewardAdvertDelegate
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    
}

@end
