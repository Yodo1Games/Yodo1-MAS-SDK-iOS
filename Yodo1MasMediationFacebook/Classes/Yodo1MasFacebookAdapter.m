//
//  Yodo1MasFacebookAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasFacebookAdapter.h"
@import FBAudienceNetwork;

#define TAG @"[Yodo1MasFacebookAdapter]"

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
    return @"0.0.0.20-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
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
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAd, loading reward ad...}", TAG];
        NSLog(message);
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        
        UIViewController * controller = [Yodo1MasFacebookAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAd:, show reward ad...}", TAG];
            NSLog(message);
            [self.rewardAd showAdFromRootViewController:controller animated:YES];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - FBRewardedVideoAdDelegate
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidClick:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidClose:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAd:didFailWithError:, reward: %@, error: %@}",TAG, rewardedVideoAd.placementID, facebookError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdVideoComplete:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    [self loadRewardAd];
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdWillLogImpression:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdServerRewardDidSucceed:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    
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
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:[self getInterstitialAdId].adId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, load interstitial ad...}",TAG];
        NSLog(message);
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasFacebookAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}",TAG];
            NSLog(message);
            [self.interstitialAd showAdFromRootViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidClick:, interstitial: %@}",TAG, interstitialAd.placementID];
    NSLog(message);
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidClose:, interstitial: %@}",TAG, interstitialAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAd];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAd:didFailWithError:, interstitial: %@, error: %@}",TAG, interstitialAd.placementID, facebookError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    
    [self nextInterstitial];
    [self loadInterstitialAd];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdWillLogImpression:, interstitial: %@}",TAG, interstitialAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerAd != nil && self.bannerAd.isAdValid;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    
    if (self.bannerAd != nil) {
        [self.bannerAd removeFromSuperview];
    }
    if ([self getBannerAdId] != nil) {
        self.bannerAd = [[FBAdView alloc] initWithPlacementID:[self getBannerAdId].adId adSize:kFBAdSize320x50 rootViewController:[Yodo1MasFacebookAdapter getTopViewController]];
        self.bannerAd.delegate = self;
    }
    if (self.bannerAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}",TAG];
        NSLog(message);
        [self.bannerAd loadAd];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}",TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasFacebookAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
    }
}

- (void)dismissBannerAd {
    [super dismissBannerAd];
    [Yodo1MasBanner removeBanner:self.bannerAd];
    self.bannerAd = nil;
}

#pragma mark - FBAdViewDelegate
- (void)adViewDidClick:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidClick:, banner: %@}",TAG, adView.placementID];
    NSLog(message);
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidFinishHandlingClick:, banner: %@}",TAG, adView.placementID];
    NSLog(message);
}

- (void)adViewDidLoad:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidLoad:, banner: %@}",TAG, adView.placementID];
    NSLog(message);
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adView:didFailWithError:, banner: %@, error: %@}",TAG, adView.placementID, facebookError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    
    [self nextBanner];
    [self loadBannerAd];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewWillLogImpression:, banner: %@}",TAG, adView.placementID];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

@end
