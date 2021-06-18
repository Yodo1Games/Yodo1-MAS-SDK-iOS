//
//  Yodo1MasUnityAdsAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasUnityAdsAdapter.h"
@import UnityAds;

#define BANNER_TAG 10007

@interface Yodo1MasUnityAdsAdapter()<UnityAdsInitializationDelegate, UnityAdsLoadDelegate, UnityAdsDelegate, UADSBannerViewDelegate,UnityAdsShowDelegate>

@property (nonatomic, strong) UADSBannerView *bannerAd;
@property(nonatomic,assign) BOOL isInterstitialAdReady;
@property(nonatomic,assign) BOOL isRewardAdReady;
@end

@implementation Yodo1MasUnityAdsAdapter

- (NSString *)advertCode {
    return @"unity";
}

- (NSString *)sdkVersion {
    return [UnityAds getVersion];
}

- (NSString *)mediationVersion {
    return @"4.2.0-beta-86031e2";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [UnityAds removeDelegate:self];
        [UnityAds addDelegate:self];
        if (config.appId != nil && config.appId.length > 0) {
            [UnityAds initialize:config.appId initializationDelegate:self];
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",self.TAG];
            NSLog(@"%@", message);
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
    NSString *message = [NSString stringWithFormat:@"%@: {method: initializationComplete, init successful}", self.TAG];
    NSLog(@"%@", message);
    
    [self updatePrivacy];
    [self loadRewardAd];
    [self loadInterstitialAd];
    [self loadBannerAd];
    if (self.initSuccessfulCallback != nil) {
        self.initSuccessfulCallback(self.advertCode);
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)adError withMessage:(NSString *)adMessage {
    NSString *message = [NSString stringWithFormat:@"%@: {method: initializationFailed:withMessage:, error: %@, message: %@}", self.TAG, @(adError), adMessage];
    NSLog(@"%@", message);
    
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
    return [self getRewardAdId] != nil && self.isRewardAdReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    self.isRewardAdReady = NO;
    if (![self isInitSDK]) return;
    if ([self getRewardAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG];
        NSLog(@"%@", message);
        [UnityAds load:[self getRewardAdId].adId loadDelegate:self];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd, show reward ad...}", self.TAG];
            NSLog(@"%@", message);
//            [UnityAds show:controller placementId:[self getRewardAdId].adId];
            [UnityAds show:controller placementId:[self getRewardAdId].adId showDelegate:self];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [self getInterstitialAdId] != nil && self.isInterstitialAdReady;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    self.isInterstitialAdReady = NO;
    if (![self isInitSDK]) return;
    if ([self getInterstitialAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", self.TAG];
        NSLog(@"%@", message);
        [UnityAds load:[self getInterstitialAdId].adId loadDelegate:self];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
//            [UnityAds show:controller placementId:[self getInterstitialAdId].adId ? : @""];
            [UnityAds show:controller placementId:[self getInterstitialAdId].adId showDelegate:self];
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return [self getBannerAdId] != nil && self.bannerAd != nil && self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    
    if (self.bannerAd != nil) {
        [self.bannerAd removeFromSuperview];
    }
    Yodo1MasAdId *adId = [self getBannerAdId];
    if (adId != nil && adId.adId != nil && (self.bannerAd == nil || ![adId.adId isEqualToString:self.bannerAd.placementId])) {
        self.bannerAd = [[UADSBannerView alloc] initWithPlacementId:adId.adId size:self.adSize];
        self.bannerAd.delegate = self;
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:[Yodo1MasUnityAdsAdapter getTopViewController]];
    }
    if (self.bannerAd != nil && self.bannerState != Yodo1MasBannerStateLoading) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}", self.TAG];
        NSLog(@"%@", message);
        [self.bannerAd load];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd tag:BANNER_TAG controller:controller object:object];
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
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

#pragma mark - UnityAdsLoadDelegate
- (void)unityAdsAdLoaded:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsAdLoaded:, placementId: %@}", self.TAG, placementId];
    NSLog(@"%@", message);
    if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
    } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
    }
}

- (void)unityAdsAdFailedToLoad:(NSString *)placementId withError:(UnityAdsLoadError)error withMessage:(nonnull NSString *)message {
    NSString *msg = [NSString stringWithFormat:@"%@: {method: unityAdsAdFailedToLoad:withError:withMessage, placementId: %@ ErrorMessage:%@}", self.TAG, placementId,message];
    NSLog(@"%@", msg);
    
    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:msg];
    if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
        [self callbackWithError:err type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAdDelayed];
    } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
        [self callbackWithError:err type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsReady:, placementId: %@}", self.TAG, placementId];
    NSLog(@"%@", message);
    if ([placementId isEqualToString:[self getInterstitialAdId].adId]) {
        self.isInterstitialAdReady = YES;
    }else{
        self.isRewardAdReady = YES;
    }
}

- (void)unityAdsDidError:(UnityAdsError)adError withMessage:(NSString *)adMessage {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsDidError:withMessage:, error: %@, message: %@}", self.TAG, @(adError), adMessage];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsDidStart:, placementId: %@}", self.TAG, placementId];
    NSLog(@"%@", message);
    
    if ([self getRewardAdId] != nil && [placementId isEqualToString:[self getRewardAdId].adId]) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    } else if ([self getInterstitialAdId] != nil && [placementId isEqualToString:[self getInterstitialAdId].adId]) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId
          withFinishState:(UnityAdsFinishState)state {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unityAdsDidFinish:, placementId: %@, state: %@}", self.TAG, placementId, @(state)];
    NSLog(@"%@", message);
    
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
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidLoad:, id: %@}", self.TAG, bannerView.placementId];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateLoaded;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
    [self callbackWithEvent:Yodo1MasAdEventCodeLoaded type:Yodo1MasAdTypeBanner];
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidClick:, id: %@}", self.TAG, bannerView.placementId];
    NSLog(@"%@", message);
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidLeaveApplication:, id: %@}", self.TAG, bannerView.placementId];
    NSLog(@"%@", message);
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerViewDidError:error:, id: %@, error: %@}", self.TAG, bannerView.placementId, adError];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)unityAdsShowClick:(nonnull NSString *)placementId {
    
}

- (void)unityAdsShowComplete:(nonnull NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    
}

- (void)unityAdsShowFailed:(nonnull NSString *)placementId withError:(UnityAdsShowError)error withMessage:(nonnull NSString *)message {
    
}

- (void)unityAdsShowStart:(nonnull NSString *)placementId {
    
}

@end
