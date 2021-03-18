//
//  DemoViewController.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "DemoViewController.h"
#import "Yodo1Mas.h"
#import <Yodo1Ads.h>
#import <Yodo1MasCore/Yodo1MasAdapterBase.h>
#import <Toast/Toast.h>
#import <AppLovinSDK/AppLovinSDK.h>

@import GoogleMobileAdsMediationTestSuite;

@interface DemoViewController ()<Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate>

@property (weak, nonatomic) IBOutlet UITextField *rewardField;
@property (weak, nonatomic) IBOutlet UITextField *intersititialField;
@property (weak, nonatomic) IBOutlet UITextField *bannerField;
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
    

    [[Yodo1Mas sharedInstance] initWithAppId:@"kU35srYo1Y6" successful:^{
        
    } fail:^(NSError * _Nonnull error) {
        
    }];
}

- (IBAction)onRewardClicked:(UIButton *)sender {
    NSString *plcement = [_rewardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (plcement != nil && plcement.length > 0) {
        [[Yodo1Mas sharedInstance] showRewardAdWithPlacement:plcement];
    } else {
        [[Yodo1Mas sharedInstance] showRewardAd];
    }
}

- (IBAction)onInterstitialClicked:(UIButton *)sender {
    NSString *plcement = [_intersititialField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (plcement != nil && plcement.length > 0) {
        [[Yodo1Mas sharedInstance] showInterstitialAdWithPlacement:plcement];
    } else {
        [[Yodo1Mas sharedInstance] showInterstitialAd];
    }
}

- (IBAction)onBannerClicked:(UIButton *)sender {
    NSString *plcement = [_bannerField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (plcement != nil && plcement.length > 0) {
        [[Yodo1Mas sharedInstance] showBannerAdWithPlacement:plcement];
    } else {
        [[Yodo1Mas sharedInstance] showBannerAd];
    }
}

- (IBAction)onHideBannerClicked:(id)sender {
    [[Yodo1Mas sharedInstance] dismissBannerAd];
}

- (IBAction)onRemoveBannerClicked:(id)sender {
    [[Yodo1Mas sharedInstance] dismissBannerAdWithDestroy:YES];
}

- (IBAction)onAdMobMediationTestClicked:(UIButton *)sender {
    [GoogleMobileAdsMediationTestSuite presentForAdManagerOnViewController:self delegate:nil];
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
    if (error.code != Yodo1MasErrorCodeAdLoadFail) {
        [[Yodo1MasAdapterBase getTopWindow] makeToast:[NSString stringWithFormat:@"Error: %@", error.userInfo[NSLocalizedDescriptionKey]]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Yodo1MasRewardAdvertDelegate
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Earned" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
