//
//  Yodo1MasUnityAdsAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasUnityAdsAdapter.h"
@import UnityAds;

#define TAG @"[Yodo1MasUnityAdsAdapter]"

@interface Yodo1MasUnityAdsAdapter()<UnityAdsInitializationDelegate, UnityAdsLoadDelegate, UnityAdsDelegate, UADSBannerViewDelegate>

@property (nonatomic, strong) UADSBannerView *bannerAd;

@end

@implementation Yodo1MasUnityAdsAdapter

- (NSString *)advertCode {
    return @"UnityAds";
}

- (NSString *)sdkVersion {
    return [UnityAds getVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.7-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [UnityAds removeDelegate:self];
        [UnityAds addDelegate:self];
        if (config.appId != nil && config.appId.length > 0) {
            [UnityAds initialize:config.appId initializationDelegate:self];
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",TAG];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
                fail(self.advertCode, error);
            }
        }
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

#pragma mark - UnityAdsInitializationDelegate
- (void)initializationComplete {
    NSString *message = [NSString stringWithFormat:@"%@: {method: initializationComplete, init successful}", TAG];
    NSLog(message);
    
    [self updatePrivacy];
    [self loadRewardAd];
    [self loadInterstitialAd];
    [self loadBannerAd];
    if (self.initSuccessfulCallback != nil) {
        self.initSuccessfulCallback(self.advertCode);
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)adError withMessage:(NSString *)adMessage {
    NSString *message = [NSString stringWithFormat:@"%@: {method: initializationFailed:withMessage:, error: %@, message: %@}", TAG, @(adError), adMessage];
    NSLog(message);
    
    if (self.initFailCallback != nil) {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
        self.initFailCallback(self.advertCode, error);
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return [UnityAds isInitialized];
}

- (void)updatePrivacy {
    [super updatePrivacy];
    UADSMetaData *metaData = [[UADSMetaData alloc] init];
    [metaData set:@"gdpr.consent" value:@([Yodo1Mas sharedInstance].isGDPRUserConsent)];
    [metaData set:@"privacy.consent" value:@([Yodo1Mas sharedInstance].isCCPADoNotSell)];
    [metaData commit];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return [self getRewardAdId] != nil && [UnityAds isReady:[self getRewardAdId].adId];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if ([self getRewardAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", TAG];
        NSLog(message);
        [UnityAds load:[self getRewardAdId].adId loadDelegate:self];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd, show reward ad...}", TAG];
            NSLog(message);
            [UnityAds show:controller placementId:[self getRewardAdId].adId];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [self getInterstitialAdId] != nil && [UnityAds isReady:[self getInterstitialAdId].adId];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if ([self getInterstitialAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", TAG];
        NSLog(message);
        [UnityAds load:[self getInterstitialAdId].adId loadDelegate:self];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd, show interstitial ad...}", TAG];
            NSLog(message);
            [UnityAds show:controller placementId:[self getInterstitialAdId].adId];
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return [self getBannerAdId] != nil && self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    
    if (self.bannerAd != nil) {
        [self.bannerAd removeFromSuperview];
    }
    if ([self getBannerAdId] != nil) {
        self.bannerAd = [[UADSBannerView alloc] initWithPlacementId:[self getBannerAdId].adId size:BANNER_SIZE_320_50];
        self.bannerAd.delegate = self;
    }
    if (self.bannerAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}", TAG];
        NSLog(message);
        [self.bannerAd load];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}", TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
    }
}

- (void)dismissBannerAd {
    [super dismissBannerAd];
    [Yodo1MasBanner removeBanner:self.bannerAd];
    self.bannerAd = nil;
    [self loadBannerAd];
}

#pragma mark - UnityAdsLoadDelegate
- (void)unityAdsAdLoaded:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsAdLoaded:, placementId: %@}", TAG, placementId];
    NSLog(message);
}

- (void)unityAdsAdFailedToLoad:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsAdFailedToLoad:, placementId: %@}", TAG, placementId];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAdDelayed];
    } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsReady:, placementId: %@}", TAG, placementId];
    NSLog(message);
}

- (void)unityAdsDidError:(UnityAdsError)adError withMessage:(NSString *)adMessage {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsDidError:withMessage:, error: %@, message: %@}", TAG, @(adError), adMessage];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsDidStart:, placementId: %@}", TAG, placementId];
    NSLog(message);
    
    if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId
          withFinishState:(UnityAdsFinishState)state {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsDidFinish:, placementId: %@, state: %@}", TAG, placementId, @(state)];
    NSLog(message);
    
    switch (state) {
        case kUnityAdsFinishStateError: {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
            if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
                [self callbackWithError:error type:Yodo1MasAdTypeReward];
                [self nextReward];
                [self loadRewardAd];
            } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
                [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
                [self nextInterstitial];
                [self loadInterstitialAd];
            }
            break;
        }
        default: {
            if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
                [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
                [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
            } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
                [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
            }
            break;
        }
    }
}

#pragma mark - UADSBannerViewDelegate
- (void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidLoad:, id: %@}", TAG, bannerView.placementId];
    NSLog(message);
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidClick:, id: %@}", TAG, bannerView.placementId];
    NSLog(message);
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidLeaveApplication:, id: %@}", TAG, bannerView.placementId];
    NSLog(message);
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidError:error:, id: %@, error: %@}", TAG, bannerView.placementId, adError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadRewardAdDelayed];
}

@end
