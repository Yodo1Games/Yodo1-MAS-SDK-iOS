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
@property (nonatomic, strong) FBAdView *bannerView;

@end

@implementation Yodo1MasFacebookAdapter

- (NSString *)advertCode {
    return @"Facebook";
}

- (NSString *)sdkVersion {
    return @"1.0.0";
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    [self updatePrivacy];
    [self loadRewardAdvert];
    [self loadInterstitialAdvert];
    [self loadBannerAdvert];
    
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
- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return self.rewardAd != nil && self.rewardAd.isAdValid;
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.rewardPlacementId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAdvert, loading reward ad...}", TAG];
        NSLog(message);
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        
        UIViewController * controller = [Yodo1MasFacebookAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAdvert:, show reward ad...}", TAG];
            NSLog(message);
            [self.rewardAd showAdFromRootViewController:controller animated:YES];
        }
    }
}

#pragma mark - FBRewardedVideoAdDelegate
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidClick:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdDidClose:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAd:didFailWithError:, reward: %@, error: %@}",TAG, rewardedVideoAd.placementID, facebookError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdVideoComplete:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    [self loadRewardAdvert];
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdWillLogImpression:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:rewardedVideoAdServerRewardDidSucceed:, reward: %@}",TAG, rewardedVideoAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return self.interstitialAd != nil && self.interstitialAd.isAdValid;
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAdvert, load interstitial ad...}",TAG];
        NSLog(message);
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasFacebookAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAdvert:, show interstitial ad...}",TAG];
            NSLog(message);
            [self.interstitialAd showAdFromRootViewController:controller];
        }
    }
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidClick:, interstitial: %@}",TAG, interstitialAd.placementID];
    NSLog(message);
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdDidClose:, interstitial: %@}",TAG, interstitialAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)facebookError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAd:didFailWithError:, interstitial: %@, error: %@}",TAG, interstitialAd.placementID, facebookError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialAdWillLogImpression:, interstitial: %@}",TAG, interstitialAd.placementID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    [super isBannerAdvertLoaded];
    return self.bannerView != nil && self.bannerView.isAdValid;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
    if (![self isInitSDK]) return;
    
    if (self.bannerView == nil && self.bannerPlacementId != nil) {
        self.bannerView = [[FBAdView alloc] initWithPlacementID:self.bannerPlacementId adSize:kFBAdSizeHeight50Banner rootViewController:[Yodo1MasFacebookAdapter getTopViewController]];
    }
    if (self.bannerView != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAdvert:, loading banner ad...}",TAG];
        NSLog(message);
        [self.bannerView loadAd];
    }
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback align:(Yodo1MasBannerAlign)align {
    [super showBannerAdvert:callback align:align];
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
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeBanner];
    [self loadBannerAdvert];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewWillLogImpression:, banner: %@}",TAG, adView.placementID];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeBanner];
}

@end
