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

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:controller callback:callback];
    if ([self isInitSDK]) {
        if ([self isRewardAdvertLoaded]) {
            if (controller == nil) {
                controller = [Yodo1MasAdMobAdapter getTopViewController];
            }
            if (controller != nil) {
                [self.rewardAd presentFromRootViewController:controller delegate:self];
            }
        } else {
            if (callback != nil) {
                callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
            }
        }
    } else {
        if (callback != nil) {
            callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
        }
    }
}

#pragma mark - GADRewardedAdDelegate
- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
didFailToPresentWithError:(nonnull NSError *)error {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventError, error);
    }
    [self loadRewardAdvert];
}

- (void)rewardedAdDidPresent:(nonnull GADRewardedAd *)rewardedAd {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventOpened, nil);
    }
}

- (void)rewardedAdDidDismiss:(nonnull GADRewardedAd *)rewardedAd {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventClosed, nil);
    }
    [self loadRewardAdvert];
}

- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
 userDidEarnReward:(nonnull GADAdReward *)reward {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventRewardEarned, nil);
    }
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

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:controller callback:callback];
    
    if ([self isInitSDK]) {
        if ([self isInterstitialAdvertLoaded]) {
            if (controller == nil) {
                controller = [Yodo1MasAdMobAdapter getTopViewController];
            }
            if (controller != nil) {
                [self.interstitialAd presentFromRootViewController:controller];
            }
        } else {
            if (callback != nil) {
                callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
            }
        }
    } else {
        if (callback != nil) {
            callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
        }
    }
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialWillPresentScreen:(nonnull GADInterstitial *)ad {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventOpened, nil);
    }
}

- (void)interstitialDidFailToPresentScreen:(nonnull GADInterstitial *)ad {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
    }
    [self loadInterstitialAdvert];
}

- (void)interstitialDidDismissScreen:(nonnull GADInterstitial *)ad {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventClosed, nil);
    }
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

- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [self showBannerAdvert:controller callback:callback];
    if ([self isInitSDK]) {
        if ([self isBannerAdvertLoaded]) {
            if (controller != nil) {
                self.bannerView.rootViewController = controller;
                self.bannerView.frame = CGRectMake(0, controller.view.bounds.size.height - 50, controller.view.bounds.size.width, 50);
                [controller.view addSubview:self.bannerView];
            } else {
                UIWindow *window = [Yodo1MasAdMobAdapter getTopWindow];
                self.bannerView.frame = CGRectMake(0, window.bounds.size.height - 50, window.bounds.size.width, 50);
                [window addSubview:self.bannerView];
            }
        } else {
            if (callback != nil) {
                callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
            }
        }
    } else {
        if (callback != nil) {
            callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
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
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventOpened, nil);
    }
}

- (void)adViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventClosed, nil);
    }
    [self loadBannerAdvert];
}

@end
