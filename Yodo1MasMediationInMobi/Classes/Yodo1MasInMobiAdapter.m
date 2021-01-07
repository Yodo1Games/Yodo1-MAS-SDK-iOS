//
//  Yodo1MasInMobiAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasInMobiAdapter.h"
@import InMobiSDK;

#define TAG @"[Yodo1MasInMobiAdapter]"

@interface Yodo1MasInMobiAdapter()<IMInterstitialDelegate, IMBannerDelegate>

@property (nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) IMInterstitial *rewardAd;
@property (nonatomic, strong) IMInterstitial *interstitialAd;
@property (nonatomic, strong) IMBanner *bannerAd;

@end

@implementation Yodo1MasInMobiAdapter

- (NSString *)advertCode {
    return @"InMobi";
}

- (NSString *)sdkVersion {
    return [IMSdk getVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        if (config.appId != nil && config.appId.length > 0) {
            self.sdkInit = YES;
            __weak __typeof(self)weakSelf = self;
            [IMSdk setLogLevel:kIMSDKLogLevelDebug];
            [IMSdk initWithAccountID:config.appId consentDictionary:nil andCompletionHandler:^(NSError * _Nullable adError) {
                NSString *message = [NSString stringWithFormat:@"%@: {method:andCompletionHandler:, error: %@}",TAG, adError];
                NSLog(message);
                
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
    
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [[IMInterstitial alloc] initWithPlacementId:[self.rewardPlacementId longLongValue]];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAd, loading reward ad...}",TAG];
        NSLog(message);
        [self.rewardAd load];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAd:, show reward ad...}",TAG];
            NSLog(message);
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
    
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:[self.interstitialPlacementId longLongValue]];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, loading interstitial ad...}",TAG];
        NSLog(message);
        [self.interstitialAd load];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object{
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}",TAG];
            NSLog(message);
            [self.interstitialAd showFromViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerPlacementId != nil && self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (self.bannerPlacementId != nil && self.bannerPlacementId.length > 0 && self.bannerAd == nil) {
        self.bannerAd = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, 320, 50) placementId:[self.bannerPlacementId longLongValue] delegate:self];
    }

    if (self.bannerAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}",TAG];
        NSLog(message);
        [self.bannerAd load];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}",TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
    }
}

- (void)dismissBannerAd {
    [super dismissBannerAd];
    [Yodo1MasBanner removeBanner:self.bannerAd];
    self.bannerAd = nil;
}

#pragma mark - IMInterstitialDelegate
- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didReceiveWithMetaInfo:, ad: %@, info: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", metaInfo.bidInfo];
    NSLog(message);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToReceiveWithError:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToReceiveWithError:, ad: %@, error: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self loadRewardAdDelayed];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial gotSignals:(NSData *)signals {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:gotSignals:, ad: %@, signals: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", signals];
    NSLog(message);
}

- (void)interstitial:(IMInterstitial *)interstitial failedToGetSignalsWithError:(IMRequestStatus *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:failedToGetSignalsWithError:, ad: %@, error: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", error];
    NSLog(message);
}

- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidFinishLoading:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToLoadWithError:, ad: %@, error: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self loadRewardAdDelayed];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillPresent:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidPresent:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
    
    if (interstitial == self.rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    } else {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)inMobiError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToPresentWithError:, ad: %@, error: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", inMobiError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillDismiss:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismiss:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
    if (interstitial == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    } else if (interstitial == _interstitialAd){
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismiss:didInteractWithParams:, ad: %@, params: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", params];
    NSLog(message);
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismiss:rewardActionCompletedWithRewards:, ad: %@, rewards: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", rewards];
    NSLog(message);
    if (interstitial == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:userWillLeaveApplicationFromInterstitial:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
}

#pragma mark - IMBannerDelegate
-(void)banner:(IMBanner*)banner gotSignals:(NSData *)signals {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:gotSignals:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);
}

-(void)banner:(IMBanner *)banner failedToGetSignalsWithError:(IMRequestStatus *)status {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:failedToGetSignalsWithError:, ad: %@, error: %@}",TAG, @(banner.placementId), status];
    NSLog(message);
}

-(void)bannerDidFinishLoading:(IMBanner *)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerDidFinishLoading:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);
}

-(void)banner:(IMBanner*)banner didReceiveWithMetaInfo:(IMAdMetaInfo *)info {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didReceiveWithMetaInfo:, ad: %@, info: %@}",TAG, @(banner.placementId), info.creativeID];
    NSLog(message);
}

-(void)banner:(IMBanner*)banner didFailToReceiveWithError:(IMRequestStatus *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didFailToReceiveWithError:, ad: %@, error: %@}",TAG, @(banner.placementId), adError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self loadBannerAdDelayed];
}

-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didFailToLoadWithError:, ad: %@, error: %@}",TAG, @(banner.placementId), adError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self loadBannerAdDelayed];
}

-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary *)params {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:didInteractWithParams:, ad: %@, params: %@}",TAG, @(banner.placementId), params];
    NSLog(message);
}

-(void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:userWillLeaveApplicationFromBanner:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);
}

-(void)bannerWillPresentScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerWillPresentScreen:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);
}

-(void)bannerDidPresentScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerDidPresentScreen:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

-(void)bannerWillDismissScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerWillDismissScreen:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);
}

-(void)bannerDidDismissScreen:(IMBanner*)banner {
    NSString *message = [NSString stringWithFormat:@"%@: {method:bannerDidDismissScreen:, ad: %@}",TAG, @(banner.placementId)];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    NSString *message = [NSString stringWithFormat:@"%@: {method:banner:rewardActionCompletedWithRewards:, ad: %@, rewards: %@}",TAG, @(banner.placementId), rewards];
    NSLog(message);
}

@end
