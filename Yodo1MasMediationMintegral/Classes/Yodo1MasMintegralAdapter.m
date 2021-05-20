//
//  Yodo1MasMintegralAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasMintegralAdapter.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <MTGSDK/MTGRewardAdInfo.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>

#define BANNER_TAG 10013

@interface Yodo1MasMintegralAdapter()<
MTGRewardAdLoadDelegate,
MTGRewardAdShowDelegate,
MTGInterstitialVideoDelegate>


@property(nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) MTGInterstitialVideoAdManager *interstitialAd;

@end

@implementation Yodo1MasMintegralAdapter

- (NSString *)advertCode {
    return @"mintegral";
}

- (NSString *)sdkVersion {
    return MTGSDK.sdkVersion;
}

- (NSString *)mediationVersion {
    return @"4.1.1-alpha-6132234";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [self updatePrivacy];
        [[MTGSDK sharedInstance]setAppID:config.appId ApiKey:config.appKey];
        self.sdkInit = YES;
        [self loadRewardAd];
        [self loadInterstitialAd];
        [self loadBannerAd];
        if (successful != nil) {
            successful(self.advertCode);
        }
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return self.sdkInit;
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [MTGSDK.sharedInstance setConsentStatus:Yodo1Mas.sharedInstance.isGDPRUserConsent];
    [MTGSDK.sharedInstance setDoNotTrackStatus:Yodo1Mas.sharedInstance.isCCPADoNotSell];
}


#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    Yodo1MasAdId *adId = [self getRewardAdId];
    BOOL isReady = [MTGRewardAdManager.sharedInstance isVideoReadyToPlayWithPlacementId:adId.adId
                                                                                 unitId:adId.adId];
    return isReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    
    Yodo1MasAdId *adId = [self getRewardAdId];
    [MTGRewardAdManager.sharedInstance loadVideoWithPlacementId:adId.adId
                                                         unitId:adId.adId
                                                       delegate:self];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasMintegralAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            Yodo1MasAdId *adId = [self getRewardAdId];
            [MTGRewardAdManager.sharedInstance showVideoWithPlacementId:adId.adId
                                                                 unitId:adId.adId
                                                           withRewardId:@"1"
                                                                 userId:@""
                                                               delegate:self
                                                         viewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    Yodo1MasAdId *adId = [self getInterstitialAdId];
    BOOL isReady = [self.interstitialAd isVideoReadyToPlayWithPlacementId:adId.adId
                                                                   unitId:adId.adId];
    return isReady;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    [self.interstitialAd loadAd];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasMintegralAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd showFromViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

- (MTGInterstitialVideoAdManager *)interstitialAd {
    if (!_interstitialAd) {
        Yodo1MasAdId *adId = [self getRewardAdId];
        _interstitialAd = [[MTGInterstitialVideoAdManager alloc]initWithPlacementId:adId.adId unitId:adId.adId delegate:self];
    }
    return _interstitialAd;
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    return [super isBannerAdLoaded];
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getBannerAdId];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    //[Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        //self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}



#pragma mark- MintegralAdDelegate

- (void)onVideoAdLoadSuccess:(nullable NSString *)placementId
                      unitId:(nullable NSString *)unitId {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)onVideoAdLoadFailed:(nullable NSString *)placementId
                     unitId:(nullable NSString *)unitId
                      error:(nonnull NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onVideoAdLoadFailed:, placementId: %@, error: %@}", self.TAG, placementId, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *yError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:yError type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}

#pragma mark- MVRewardAdShowDelegate
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId
                      unitId:(nullable NSString *)unitId {
    
}

- (void)onVideoAdShowFailed:(nullable NSString *)placementId
                     unitId:(nullable NSString *)unitId
                  withError:(nonnull NSError *)error {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: onVideoAdShowFailed:, placementId: %@, error: %@}", self.TAG, placementId, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *yError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:yError type:Yodo1MasAdTypeReward];
}

- (void) onVideoPlayCompleted:(nullable NSString *)placementId
                       unitId:(nullable NSString *)unitId {
    
}

- (void) onVideoEndCardShowSuccess:(nullable NSString *)placementId
                            unitId:(nullable NSString *)unitId {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)onVideoAdClicked:(nullable NSString *)placementId
                  unitId:(nullable NSString *)unitId {
    
}

- (void)onVideoAdDismissed:(nullable NSString *)placementId
                    unitId:(nullable NSString *)unitId
             withConverted:(BOOL)converted
            withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo {
    if (converted) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

- (void)onVideoAdDidClosed:(nullable NSString *)placementId
                    unitId:(nullable NSString *)unitId {
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self nextReward];
    [self loadRewardAd];
}



#pragma mark- MTGInterstitialVideoDelegate

- (void) onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void) onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onInterstitialVideoLoadFail:, placementId: %@, error: %@}", self.TAG, adManager.placementId, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *yError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:yError type:Yodo1MasAdTypeInterstitial];
    [self nextInterstitial];
    [self loadInterstitialAd];
}

- (void) onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void) onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onInterstitialVideoShowFail:, placementId: %@, error: %@}", self.TAG, adManager.placementId, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *yError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:yError type:Yodo1MasAdTypeInterstitial];
}

- (void) onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    
}

- (void) onInterstitialVideoAdDidClosed:(MTGInterstitialVideoAdManager *_Nonnull)adManager {
    self.interstitialAd = nil;
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self nextInterstitial];
    [self loadInterstitialAd];
}


@end
