//
//  Yodo1MasAdMobAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdMobAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define BANNER_TAG 10001

@interface Yodo1MasAdMobAdapter()<GADRewardedAdDelegate, GADInterstitialDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) GADMobileAds *sdk;
@property (nonatomic, strong) GADRewardedAd *rewardAd;
@property (nonatomic, strong) GADInterstitial *interstitialAd;
@property (nonatomic, strong) GADBannerView *bannerAd;

@end

@implementation Yodo1MasAdMobAdapter

- (NSString *)advertCode {
    return @"admob";
}

- (NSString *)sdkVersion {
    return [GADMobileAds sharedInstance].sdkVersion;
}

- (NSString *)mediationVersion {
    return @"4.0.1.0";
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
            
            [weakSelf updatePrivacy];
            [weakSelf loadRewardAd];
            [weakSelf loadInterstitialAd];
            [weakSelf loadBannerAd];
            
            if (successful != nil) {
                successful(weakSelf.advertCode);
            }
            
            NSLog(@"%@: {method: GADInitializationCompletionHandler, status: %@}", self.TAG, status);
        }];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    if (self.sdk == nil) {
        return NO;
    } else {
        NSDictionary<NSString *, GADAdapterStatus *> *adapters = self.sdk.initializationStatus.adapterStatusesByClassName;
        GADAdapterStatus *status = adapters[NSStringFromClass([GADMobileAds class])];
        return status != nil && status.state == GADAdapterInitializationStateReady;
    }
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [[NSUserDefaults standardUserDefaults] setBool:[Yodo1Mas sharedInstance].isGDPRUserConsent forKey:@"gad_npa"];
    [[GADMobileAds sharedInstance].requestConfiguration tagForChildDirectedTreatment:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [[GADMobileAds sharedInstance].requestConfiguration tagForUnderAgeOfConsent:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [[NSUserDefaults standardUserDefaults] setBool:[Yodo1Mas sharedInstance].isCCPADoNotSell forKey:@"gad_rdp"];
}


#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    
    Yodo1MasAdId *adId = [self getRewardAdId];
    if (adId != nil && adId.adId != nil && (self.rewardAd == nil || ![adId.adId isEqualToString:self.rewardAd.adUnitID])) {
        self.rewardAd = [[GADRewardedAd alloc] initWithAdUnitID:adId.adId];
    }
    
    if (self.rewardAd != nil) {
        NSLog(@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG);
        
        __weak __typeof(self)weakSelf = self;
        [self.rewardAd loadRequest:[GADRequest request] completionHandler:^(GADRequestError * _Nullable adError) {
            if (adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@:{method: GADRewardedAdLoadCompletionHandler, error: %@}", self.TAG, adError];
                NSLog(@"%@", message);

                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
                [weakSelf callbackWithError:error type:Yodo1MasAdTypeReward];
                [weakSelf loadRewardAdDelayed];
            }
        }];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [self.rewardAd presentFromRootViewController:controller delegate:self];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - GADRewardedAdDelegate
- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
didFailToPresentWithError:(nonnull NSError *)adMobError {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:didFailToPresentWithError:, reward:%@, error: %@}", self.TAG, rewardedAd.adUnitID, adMobError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedAdDidPresent:(nonnull GADRewardedAd *)rewardedAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidPresent:, reward: %@}", self.TAG, rewardedAd.adUnitID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedAdDidDismiss:(nonnull GADRewardedAd *)rewardedAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidDismiss:, reward: %@}", self.TAG, rewardedAd.adUnitID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
 userDidEarnReward:(nonnull GADAdReward *)reward {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:userDidEarnReward:, reward: %@}", self.TAG, rewardedAd.adUnitID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return self.interstitialAd != nil && self.interstitialAd.isReady;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    
    Yodo1MasAdId *adId = [self getInterstitialAdId];
    if (adId != nil && adId.adId != nil && (self.interstitialAd == nil || ![adId.adId isEqualToString:self.interstitialAd.adUnitID])) {
        self.interstitialAd = [[GADInterstitial alloc] initWithAdUnitID:adId.adId];
        self.interstitialAd.delegate = self;
    }
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, loading interstitial ad...}", self.TAG];
        NSLog(@"%@", message);
        [self.interstitialAd loadRequest:[GADRequest request]];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd presentFromRootViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidReceiveAd, ad: %@}", self.TAG, ad.adUnitID];
    NSLog(@"%@", message);
}

- (void)interstitial:(nonnull GADInterstitial *)ad
didFailToReceiveAdWithError:(nonnull GADRequestError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToReceiveAdWithError, ad: %@, error: %@}", self.TAG, ad.adUnitID, adError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialWillPresentScreen:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillPresentScreen:, ad: %@}", self.TAG, ad.adUnitID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidFailToPresentScreen:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidFailToPresentScreen:, ad: %@, show interstitial ad failed}", self.TAG, ad.adUnitID];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    
    [self nextInterstitial];
    [self loadInterstitialAd];
}

- (void)interstitialDidDismissScreen:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismissScreen:, ad: %@}", self.TAG, ad.adUnitID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAd];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillDismissScreen:, ad: %@}", self.TAG, ad.adUnitID];
    NSLog(@"%@", message);
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerAd != nil && self.bannerAd.adUnitID != nil && self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getBannerAdId];
    if (adId != nil && adId.adId != nil && (self.bannerAd == nil || ![adId.adId isEqualToString:self.bannerAd.adUnitID])) {
        
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        
        self.bannerAd = [[GADBannerView alloc]
                            initWithAdSize:kGADAdSizeBanner];
        self.bannerAd.rootViewController = controller;
        self.bannerAd.adUnitID = adId.adId;
        self.bannerAd.delegate = self;
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:controller];
    }
    if (self.bannerAd != nil && self.bannerState != Yodo1MasBannerStateLoading) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}", self.TAG];
        NSLog(@"%@", message);
        [self.bannerAd loadRequest:[GADRequest request]];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            self.bannerAd.rootViewController = controller;
        }
        [Yodo1MasBanner showBannerWithTag:BANNER_TAG controller:controller object:object];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidReceiveAd:, banner: %@}", self.TAG, bannerView.adUnitID];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateLoaded;
}

- (void)adView:(nonnull GADBannerView *)bannerView
didFailToReceiveAdWithError:(nonnull GADRequestError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adView:didFailToReceiveAdWithError:, banner: %@, error: %@}", self.TAG, bannerView.adUnitID, adError];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)adViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewWillPresentScreen:, banner: %@}", self.TAG, bannerView.adUnitID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)adViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidDismissScreen:, banner: %@}", self.TAG, bannerView.adUnitID];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

@end
