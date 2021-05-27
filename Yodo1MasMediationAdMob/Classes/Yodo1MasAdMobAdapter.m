//
//  Yodo1MasAdMobAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdMobAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define BANNER_TAG 10001

@interface Yodo1MasAdMobAdapter()<GADFullScreenContentDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) GADMobileAds *sdk;
@property (nonatomic, strong) GADRewardedAd *rewardAd;
@property (nonatomic, strong) GADInterstitialAd *interstitialAd;
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
    return @"4.2.0-beta-e8851dd";
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
    return self.rewardAd != nil;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    
    Yodo1MasAdId *adId = [self getRewardAdId];
    if (adId != nil && adId.adId != nil && (self.rewardAd == nil || ![adId.adId isEqualToString:self.rewardAd.adUnitID])) {
        NSLog(@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG);
        [GADRewardedAd loadWithAdUnitID:adId.adId request:[GADRequest request] completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            if (error != nil) {
                NSString *message = [NSString stringWithFormat:@"%@:{method: loadWithAdUnitID:request:completionHandler:, error: %@}", self.TAG, error];
                NSLog(@"%@", message);
                
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
                [self callbackWithError:error type:Yodo1MasAdTypeReward];
                [self loadRewardAdDelayed];
            }else{
                self.rewardAd = rewardedAd;
                self.rewardAd.fullScreenContentDelegate = self;
                [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
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
            [self.rewardAd presentFromRootViewController:controller userDidEarnRewardHandler:^{
                NSString *message = [NSString stringWithFormat:@"%@: {method: presentFromRootViewController:userDidEarnRewardHandler:, reward: %@}", self.TAG, self.rewardAd.adReward];
                NSLog(@"%@", message);
                
                [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
            }];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - GADRewardedAdDelegate

/// Tells the delegate that an impression has been recorded for the ad.
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidPresent:, reward: %@}", self.TAG, self.rewardAd.adUnitID];
        NSLog(@"%@", message);
        
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    }else{
        NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillPresentScreen:, ad: %@}", self.TAG, self.interstitialAd.adUnitID];
        NSLog(@"%@", message);
        
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: ad:didFailToPresentFullScreenContentWithError:, reward:%@, error: %@}", self.TAG, self.rewardAd.adUnitID, error];
        NSLog(@"%@", message);
        
        Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
        [self callbackWithError:err type:Yodo1MasAdTypeReward];
        
        [self nextReward];
        [self loadRewardAd];
    }else{
        NSString *message = [NSString stringWithFormat:@"%@: {method:ad:didFailToPresentFullScreenContentWithError, ad: %@, error: %@}", self.TAG, self.interstitialAd.adUnitID, error];
        NSLog(@"%@", message);
        
        Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
        [self callbackWithError:err type:Yodo1MasAdTypeInterstitial];
        
        [self nextInterstitial];
        [self loadInterstitialAd];
    }
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    if ([ad isKindOfClass:[GADRewardedAd class]]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: adDidDismissFullScreenContent:, reward: %@}", self.TAG, self.rewardAd.adUnitID];
        NSLog(@"%@", message);
        
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
        [self loadRewardAd];
    }else{
        NSString *message = [NSString stringWithFormat:@"%@: {method:adDidDismissFullScreenContent:, ad: %@}", self.TAG, self.interstitialAd.adUnitID];
        NSLog(@"%@", message);
        
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
        [self loadInterstitialAd];
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return self.interstitialAd != nil;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    
    Yodo1MasAdId *adId = [self getInterstitialAdId];
    if (adId != nil && adId.adId != nil && (self.interstitialAd == nil || ![adId.adId isEqualToString:self.interstitialAd.adUnitID])) {
        [GADInterstitialAd loadWithAdUnitID:adId.adId request:[GADRequest request] completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error != nil) {
                NSString *message = [NSString stringWithFormat:@"%@:{method: loadWithAdUnitID:request:completionHandler:, error: %@}", self.TAG, error];
                NSLog(@"%@", message);
                
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
                [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
                
                [self nextInterstitial];
                [self loadInterstitialAdDelayed];
            }else{
                self.interstitialAd = interstitialAd;
                self.interstitialAd.fullScreenContentDelegate = self;
            }
        }];
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
        self.bannerAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
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
        [Yodo1MasBanner showBanner:self.bannerAd tag:BANNER_TAG controller:controller object:object];
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
- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidReceiveAd:, banner: %@}", self.TAG, bannerView.adUnitID];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateLoaded;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
}

- (void)bannerView:(nonnull GADBannerView *)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adView:didFailToReceiveAdWithError:, banner: %@, error: %@}", self.TAG, bannerView.adUnitID, error];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    
    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:err type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewWillPresentScreen:, banner: %@}", self.TAG, bannerView.adUnitID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidDismissScreen:, banner: %@}", self.TAG, bannerView.adUnitID];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

@end
