//
//  Yodo1MasInMobiAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasInMobiAdapter.h"
@import InMobiSDK;

#define BANNER_TAG 10004

@interface Yodo1MasInMobiAdapter()<IMInterstitialDelegate, IMBannerDelegate>

@property (nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) IMInterstitial *rewardAd;
@property (nonatomic, strong) IMInterstitial *interstitialAd;
@property (nonatomic, strong) IMBanner *bannerAd;
@property (nonatomic, copy) NSString *currentBannerId;

@end

@implementation Yodo1MasInMobiAdapter

- (NSString *)advertCode {
    return @"InMobi";
}

- (NSString *)sdkVersion {
    return [IMSdk getVersion];
}

- (NSString *)mediationVersion {
    return @"4.0.0.6";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        if (config.appId != nil && config.appId.length > 0) {
            self.sdkInit = YES;
            __weak __typeof(self)weakSelf = self;
            [IMSdk setLogLevel:kIMSDKLogLevelDebug];
            [IMSdk initWithAccountID:config.appId consentDictionary:nil andCompletionHandler:^(NSError * _Nullable adError) {
                NSString *message = [NSString stringWithFormat:@"%@: {method:andCompletionHandler:, error: %@}",self.TAG, adError];
                NSLog(@"%@", message);
                
                if (adError == nil) {
                    [weakSelf updatePrivacy];
                    [weakSelf loadRewardAd];
                    [weakSelf loadInterstitialAd];
                    [weakSelf loadBannerAd];
                    
                    if (successful != nil) {
                        successful(weakSelf.advertCode);
                    }
                } else {
                    if (fail != nil) {
                        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
                        fail(weakSelf.advertCode, error);
                    }
                }
            }];
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

- (BOOL)isInitSDK {
    [super isInitSDK];
    return self.sdkInit;
}

- (void)updatePrivacy {
    [super updatePrivacy];
    if ([Yodo1Mas sharedInstance].isGDPRUserConsent) {
        [IMSdk updateGDPRConsent:@{IM_GDPR_CONSENT_AVAILABLE : @"true", @"gdpr" : @1}];
    } else {
        [IMSdk updateGDPRConsent:@{IM_GDPR_CONSENT_AVAILABLE : @"false", @"gdpr" : @0}];
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    
    if ([self getRewardAdId] != nil) {
        self.rewardAd = [[IMInterstitial alloc] initWithPlacementId:[[self getRewardAdId].adId longLongValue]];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAd, loading reward ad...}",self.TAG];
        NSLog(@"%@", message);
        [self.rewardAd load];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAd:, show reward ad...}",self.TAG];
            NSLog(@"%@", message);
            [self.rewardAd showFromViewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
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
    if (adId != nil && adId.adId != nil) {
        self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:[adId.adId longLongValue]];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, loading interstitial ad...}",self.TAG];
        NSLog(@"%@", message);
        [self.interstitialAd load];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}",self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd showFromViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return [self getBannerAdId] != nil && self.bannerAd != nil && self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];

    Yodo1MasAdId *adId = [self getBannerAdId];
    if (adId != nil && adId.adId != nil && (self.currentBannerId == nil || ![self.currentBannerId isEqualToString:adId.adId])) {
        self.bannerAd = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, BANNER_SIZE_320_50.width, BANNER_SIZE_320_50.height) placementId:[adId.adId longLongValue] delegate:self];
        self.currentBannerId = adId.adId;
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:[Yodo1MasInMobiAdapter getTopViewController]];
    }

    if (self.bannerAd != nil && self.bannerState != Yodo1MasBannerStateLoading) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}",self.TAG];
        NSLog(@"%@", message);
        [self.bannerAd load];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}",self.TAG];
        NSLog(@"%@", message);
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        [Yodo1MasBanner showBannerWithTag:BANNER_TAG controller:controller object:object];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        self.currentBannerId = nil;
        [self loadBannerAd];
    }
}

#pragma mark - IMInterstitialDelegate
- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didReceiveWithMetaInfo:, ad: %@, info: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", metaInfo.bidInfo];
    NSLog(@"%@", message);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToReceiveWithError:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToReceiveWithError:, ad: %@, error: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", adError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAdDelayed];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial gotSignals:(NSData *)signals {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:gotSignals:, ad: %@, signals: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", signals];
    NSLog(@"%@", message);
}

- (void)interstitial:(IMInterstitial *)interstitial failedToGetSignalsWithError:(IMRequestStatus *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:failedToGetSignalsWithError:, ad: %@, error: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", error];
    NSLog(@"%@", message);
}

- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidFinishLoading:, ad: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(@"%@", message);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToLoadWithError:, ad: %@, error: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", adError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAdDelayed];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillPresent:, ad: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(@"%@", message);
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidPresent:, ad: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(@"%@", message);
    
    if (interstitial == self.rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    } else {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)inMobiError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToPresentWithError:, ad: %@, error: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", inMobiError];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAd];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAd];
    }
}

- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillDismiss:, ad: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(@"%@", message);
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismiss:, ad: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(@"%@", message);
    if (interstitial == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
        [self loadRewardAd];
    } else if (interstitial == _interstitialAd){
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
        [self loadInterstitialAd];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismiss:didInteractWithParams:, ad: %@, params: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", params];
    NSLog(@"%@", message);
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismiss:rewardActionCompletedWithRewards:, ad: %@, rewards: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", rewards];
    NSLog(@"%@", message);
    if (interstitial == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:userWillLeaveApplicationFromInterstitial:, ad: %@}",self.TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(@"%@", message);
}

#pragma mark - IMBannerDelegate
- (void)banner:(IMBanner*)banner gotSignals:(NSData *)signals {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:gotSignals:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);
}

- (void)banner:(IMBanner *)banner failedToGetSignalsWithError:(IMRequestStatus *)status {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:failedToGetSignalsWithError:, ad: %@, error: %@}",self.TAG, @(banner.placementId), status];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
}

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerDidFinishLoading:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateLoaded;
}

- (void)banner:(IMBanner*)banner didReceiveWithMetaInfo:(IMAdMetaInfo *)info {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didReceiveWithMetaInfo:, ad: %@, info: %@}",self.TAG, @(banner.placementId), info.creativeID];
    NSLog(@"%@", message);
}

- (void)banner:(IMBanner*)banner didFailToReceiveWithError:(IMRequestStatus *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didFailToReceiveWithError:, ad: %@, error: %@}",self.TAG, @(banner.placementId), adError];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didFailToLoadWithError:, ad: %@, error: %@}",self.TAG, @(banner.placementId), adError];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary *)params {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didInteractWithParams:, ad: %@, params: %@}",self.TAG, @(banner.placementId), params];
    NSLog(@"%@", message);
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:userWillLeaveApplicationFromBanner:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);
}

- (void)bannerWillPresentScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerWillPresentScreen:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);
}

- (void)bannerDidPresentScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerDidPresentScreen:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);

    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)bannerWillDismissScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerWillDismissScreen:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);
}

- (void)bannerDidDismissScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerDidDismissScreen:, ad: %@}",self.TAG, @(banner.placementId)];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

- (void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:rewardActionCompletedWithRewards:, ad: %@, rewards: %@}",self.TAG, @(banner.placementId), rewards];
    NSLog(@"%@", message);
}

@end
