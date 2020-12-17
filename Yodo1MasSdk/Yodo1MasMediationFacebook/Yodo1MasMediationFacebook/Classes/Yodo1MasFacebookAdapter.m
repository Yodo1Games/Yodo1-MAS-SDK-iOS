//
//  Yodo1MasFacebookAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasFacebookAdapter.h"
@import FBAudienceNetwork;

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
    if (successful != nil) {
        successful(self.advertCode);
    }
    
    [self updatePrivacy];
    [self loadRewardAdvert];
    [self loadInterstitialAdvert];
    [self loadBannerAdvert];
}

- (BOOL)isInitSDK {
    return YES;
}

- (void)updatePrivacy {
    [FBAdSettings setMixedAudience:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardAd != nil && self.rewardAd.isAdValid;
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.rewardPlacementId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        if (controller == nil) {
            controller == [Yodo1MasFacebookAdapter getTopViewController];
        }
        if (controller != nil) {
            [self.rewardAd showAdFromRootViewController:controller animated:YES];
        }
    }
}

#pragma mark - FBRewardedVideoAdDelegate
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)facebookError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:facebookError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    [self loadRewardAdvert];
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialAd != nil && self.interstitialAd.isAdValid;
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        if (controller == nil) {
            controller == [Yodo1MasFacebookAdapter getTopViewController];
        }
        if (controller != nil) {
            [self.interstitialAd showAdFromRootViewController:controller];
        }
    }
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)facebookError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:facebookError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return self.bannerView != nil && self.bannerView.isAdValid;
}

- (void)loadBannerAdvert {
    if (![self isInitSDK]) return;
    
    if (self.bannerView == nil && self.bannerPlacementId != nil) {
        self.bannerView = [[FBAdView alloc] initWithPlacementID:self.bannerPlacementId adSize:kFBAdSizeHeight50Banner rootViewController:[Yodo1MasFacebookAdapter getTopViewController]];
    }
    if (self.bannerView != nil) {
        [self.bannerView loadAd];
    }
}

- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:controller callback:callback];
}

#pragma mark - FBAdViewDelegate
- (void)adViewDidClick:(FBAdView *)adView {
    
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    
}

- (void)adViewDidLoad:(FBAdView *)adView {
    
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)facebookError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:facebookError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeBanner];
    [self loadBannerAdvert];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeBanner];
}

@end
