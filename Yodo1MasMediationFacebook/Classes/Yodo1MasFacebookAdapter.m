//
//  Yodo1MasFacebookAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasFacebookAdapter.h"
@import FBAudienceNetwork;

#define BANNER_TAG 10003

@interface Yodo1MasFacebookAdapter()<FBRewardedVideoAdDelegate, FBInterstitialAdDelegate, FBAdViewDelegate>

@property (nonatomic, strong) FBRewardedVideoAd *rewardAd;
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@property (nonatomic, strong) FBAdView *bannerAd;

@end

@implementation Yodo1MasFacebookAdapter

- (NSString *)advertCode {
    return @"facebook";
}

- (NSString *)sdkVersion {
    return @"6.2.0";
}

- (NSString *)mediationVersion {
    return @"4.2.0";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    [FBAdSettings setAdvertiserTrackingEnabled:YES];
    [self updatePrivacy];
    [self loadRewardAd];
    [self loadInterstitialAd];
    [self loadBannerAd];
    
    if (successful != nil) {
        successful(self.advertCode);
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return YES;
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [FBAdSettings setMixedAudience:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return self.rewardAd != nil && self.rewardAd.isAdValid;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if ([self getRewardAdId] != nil) {
        self.rewardAd = [[FBRewardedVideoAd alloc] initWithPlacementID:[self getRewardAdId].adId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAd, loading reward ad...}", self.TAG];
        NSLog(@"%@", message);
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        
        UIViewController * controller = [Yodo1MasFacebookAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAd:, show reward ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.rewardAd showAdFromRootViewController:controller animated:YES];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - FBRewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidLoad:, reward: %@}",self.TAG, rewardedVideoAd.placementID];
    NSLog(@"%@", message);
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidClick:, reward: %@}",self.TAG, rewardedVideoAd.placementID];
    NSLog(@"%@", message);
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidClose:, reward: %@}",self.TAG, rewardedVideoAd.placementID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAd:didFailWithError:, reward: %@, error: %@}",self.TAG, rewardedVideoAd.placementID, facebookError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    
    [self nextReward];
    [self loadRewardAdDelayed];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdVideoComplete:, reward: %@}",self.TAG, rewardedVideoAd.placementID];
    NSLog(@"%@", message);
    [self loadRewardAd];
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdWillLogImpression:, reward: %@}",self.TAG, rewardedVideoAd.placementID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdServerRewardDidSucceed:, reward: %@}",self.TAG, rewardedVideoAd.placementID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return self.interstitialAd != nil && self.interstitialAd.isAdValid;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    
    if ([self getInterstitialAdId] != nil) {
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:[self getInterstitialAdId].adId ? : @""];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, load interstitial ad...}",self.TAG];
        NSLog(@"%@", message);
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasFacebookAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}",self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd showAdFromRootViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidLoad:, interstitial: %@}",self.TAG, interstitialAd.placementID];
    NSLog(@"%@", message);
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidClick:, interstitial: %@}",self.TAG, interstitialAd.placementID];
    NSLog(@"%@", message);
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidClose:, interstitial: %@}",self.TAG, interstitialAd.placementID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAd];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAd:didFailWithError:, interstitial: %@, error: %@}",self.TAG, interstitialAd.placementID, facebookError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdWillLogImpression:, interstitial: %@}",self.TAG, interstitialAd.placementID];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerAd != nil && self.bannerAd.isAdValid && self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    
    Yodo1MasAdId *adId = [self getBannerAdId];
    if (adId != nil && adId.adId != nil && (self.bannerAd == nil || ![adId.adId isEqualToString:self.bannerAd.placementID])) {
        UIViewController *controller = [Yodo1MasFacebookAdapter getTopViewController];
        self.bannerAd = [[FBAdView alloc] initWithPlacementID:adId.adId adSize:kFBAdSize320x50 rootViewController:controller];
        self.bannerAd.delegate = self;
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:controller];
    }
    if (self.bannerAd != nil && self.bannerState != Yodo1MasBannerStateLoading) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}",self.TAG];
        NSLog(@"%@", message);
        [self.bannerAd loadAd];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}",self.TAG];
        NSLog(@"%@", message);
        UIViewController *controller = [Yodo1MasFacebookAdapter getTopViewController];
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

#pragma mark - FBAdViewDelegate
- (void)adViewDidClick:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidClick:, banner: %@}",self.TAG, adView.placementID];
    NSLog(@"%@", message);
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidFinishHandlingClick:, banner: %@}",self.TAG, adView.placementID];
    NSLog(@"%@", message);
}

- (void)adViewDidLoad:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidLoad:, banner: %@}",self.TAG, adView.placementID];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateLoaded;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adView:didFailWithError:, banner: %@, error: %@}",self.TAG, adView.placementID, facebookError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    self.bannerState = Yodo1MasBannerStateNone;
    [self nextBanner];
    [self loadBannerAd];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewWillLogImpression:, banner: %@}",self.TAG, adView.placementID];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

@end
