//
//  Yodo1MasAdMobAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdMobAdapter.h"
@import GoogleMobileAds;

@interface Yodo1MasAdMobAdapter()<GADRewardedAdDelegate, GADInterstitialDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) GADMobileAds *sdk;
@property (nonatomic, strong) GADRewardedAd *rewardAd;
@property (nonatomic, strong) GADInterstitial *interstitialAd;
@property (nonatomic, strong) GADBannerView *bannerView;

@end

@implementation Yodo1MasAdMobAdapter

- (NSString *)advertCode {
    return @"AdMob";
}

- (NSString *)sdkVersion {
    return [GADMobileAds sharedInstance].sdkVersion;
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (self.sdk == nil) {
        self.sdk = [GADMobileAds sharedInstance];
    }
    if (![self isInitSDK]) {
        if (!self.isMax) {
            [self.sdk disableMediationInitialization];
        }
        __weak __typeof(self)weakSelf = self;
        [self.sdk startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
            if (successful != nil) {
                successful(weakSelf.advertCode);
            }
            [weakSelf updatePrivacy];
            [weakSelf loadRewardAdvert];
            [weakSelf loadInterstitialAdvert];
            [weakSelf loadBannerAdvert];
        }];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    if (self.sdk == nil) {
        return NO;
    } else {
        NSDictionary<NSString *, GADAdapterStatus *> *adapters = self.sdk.initializationStatus.adapterStatusesByClassName;
        GADAdapterStatus *status = adapters[NSStringFromClass([GADMobileAds class])];
        return status != nil && status.state == GADAdapterInitializationStateReady;
    }
}

- (void)updatePrivacy {
    [[NSUserDefaults standardUserDefaults] setBool:[Yodo1Mas sharedInstance].isGDPRUserConsent forKey:@"gad_npa"];
    [[GADMobileAds sharedInstance].requestConfiguration tagForChildDirectedTreatment:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [[GADMobileAds sharedInstance].requestConfiguration tagForUnderAgeOfConsent:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [[NSUserDefaults standardUserDefaults] setBool:[Yodo1Mas sharedInstance].isCCPADoNotSell forKey:@"gad_rdp"];
}


#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    
    if (self.rewardPlacementId != nil) {
        self.rewardAd = [[GADRewardedAd alloc] initWithAdUnitID:self.rewardPlacementId];
    }
    
    if (self.rewardAd != nil) {
        [self.rewardAd loadRequest:[GADRequest request] completionHandler:^(GADRequestError * _Nullable error) {
                    
        }];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            [self.rewardAd presentFromRootViewController:controller delegate:self];
        }
    }
}

#pragma mark - GADRewardedAdDelegate
- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
didFailToPresentWithError:(nonnull NSError *)adMobError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:adMobError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedAdDidPresent:(nonnull GADRewardedAd *)rewardedAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedAdDidDismiss:(nonnull GADRewardedAd *)rewardedAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
 userDidEarnReward:(nonnull GADAdReward *)reward {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialAd != nil && self.interstitialAd.isReady;
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    
    if (self.interstitialPlacementId != nil) {
        self.interstitialAd = [[GADInterstitial alloc] initWithAdUnitID:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    if (self.interstitialAd != nil) {
        [self.interstitialAd loadRequest:[GADRequest request]];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        
        if (controller != nil) {
            [self.interstitialAd presentFromRootViewController:controller];
        }
    }
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialWillPresentScreen:(nonnull GADInterstitial *)ad {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidFailToPresentScreen:(nonnull GADInterstitial *)ad {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:@"show interstitial ad failed"];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialDidDismissScreen:(nonnull GADInterstitial *)ad {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return self.bannerView != nil;
}

- (void)loadBannerAdvert {
    if (![self isInitSDK]) return;
    if (self.bannerView == nil && self.bannerPlacementId != nil) {
        self.bannerView == [[GADBannerView alloc]
                            initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerView.adUnitID = self.bannerPlacementId;
        self.bannerView.delegate = self;
    }
    if (self.bannerView != nil) {
        [self.bannerView loadRequest:[GADRequest request]];
    }
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback {
    [self showBannerAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            self.bannerView.rootViewController = controller;
            self.bannerView.frame = CGRectMake(0, controller.view.bounds.size.height - 50, controller.view.bounds.size.width, 50);
            [controller.view addSubview:self.bannerView];
        } else {
            UIWindow *window = [Yodo1MasAdMobAdapter getTopWindow];
            self.bannerView.frame = CGRectMake(0, window.bounds.size.height - 50, window.bounds.size.width, 50);
            [window addSubview:self.bannerView];
        }
    }
}

- (void)dismissBannerAdvert {
    [super dismissBannerAdvert];
    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
    }
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    
}

- (void)adView:(nonnull GADBannerView *)bannerView
didFailToReceiveAdWithError:(nonnull GADRequestError *)error {
    
}

- (void)adViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeBanner];
}

- (void)adViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeBanner];
    [self loadBannerAdvert];
}

@end
