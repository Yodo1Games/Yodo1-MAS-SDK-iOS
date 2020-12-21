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

@interface DemoViewController ()

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
}

- (IBAction)onRewardClicked:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    [[Yodo1Mas sharedInstance] showRewardAdvert:self callback:^(Yodo1MasAdvertEvent *event) {
        if (event.code == Yodo1MasAdvertEventCodeError) {
            [weakSelf.view makeToast:event.error.userInfo[NSLocalizedDescriptionKey]];
        }
    }];
}

- (IBAction)onInterstitialClicked:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    [[Yodo1Mas sharedInstance] showInterstitialAdvert:self callback:^(Yodo1MasAdvertEvent *event) {
        if (event.code == Yodo1MasAdvertEventCodeError) {
            [weakSelf.view makeToast:event.error.userInfo[NSLocalizedDescriptionKey]];
        }
    }];
}

- (IBAction)onBannerClicked:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    [[Yodo1Mas sharedInstance] showBannerAdvert:self callback:^(Yodo1MasAdvertEvent *event) {
        if (event.code == Yodo1MasAdvertEventCodeError) {
            [weakSelf.view makeToast:event.error.userInfo[NSLocalizedDescriptionKey]];
        }
    }];
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

@end
