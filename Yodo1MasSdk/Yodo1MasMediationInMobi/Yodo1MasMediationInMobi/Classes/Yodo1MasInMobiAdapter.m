//
//  Yodo1MasInMobiAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasInMobiAdapter.h"
@import InMobiSDK;

#define TAG @"[Yodo1MasInMobiAdapter]"

@interface Yodo1MasInMobiAdapter()<IMInterstitialDelegate>

@property (nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) IMInterstitial *rewardAd;
@property (nonatomic, strong) IMInterstitial *interstitialAd;
@property (nonatomic, strong) IMBanner *bannerView;

@end

@implementation Yodo1MasInMobiAdapter

- (NSString *)advertCode {
    return @"InMobi";
}

- (NSString *)sdkVersion {
    [IMSdk getVersion];
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
                    [weakSelf loadRewardAdvert];
                    [weakSelf loadInterstitialAdvert];
                    [weakSelf loadBannerAdvert];
                    
                    if (successful != nil) {
                        successful(weakSelf.advertCode);
                    }
                } else {
                    if (fail != nil) {
                        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
                        fail(weakSelf.advertCode, error);
                    }
                }
            }];
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",TAG];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
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
- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [[IMInterstitial alloc] initWithPlacementId:[self.rewardPlacementId longLongValue]];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAdvert, loading reward ad...}",TAG];
        NSLog(message);
        [self.rewardAd load];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAdvert:, show reward ad...}",TAG];
            NSLog(message);
            [self.rewardAd showFromViewController:controller];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return self.interstitialAd != nil && self.interstitialAd.isReady;
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:[self.interstitialPlacementId longLongValue]];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAdvert, loading interstitial ad...}",TAG];
        NSLog(message);
        [self.interstitialAd load];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasInMobiAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAdvert:, show interstitial ad...}",TAG];
            NSLog(message);
            [self.interstitialAd showFromViewController:controller];
        }
    }
}

#pragma mark - 横幅广告

- (BOOL)isBannerAdvertLoaded {
    [super isBannerAdvertLoaded];
    return NO;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:callback];
}

#pragma mark - IMInterstitialDelegate
- (void)interstitial:(IMInterstitial *)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo *)metaInfo {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didReceiveWithMetaInfo:, ad: %@, info: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", metaInfo.bidInfo];
    NSLog(message);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToReceiveWithError:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToReceiveWithError:, ad: %@, error: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
        [self loadRewardAdvertDelayed];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
        [self loadInterstitialAdvertDelayed];
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
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
        [self loadRewardAdvertDelayed];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
        [self loadInterstitialAdvertDelayed];
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
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
    } else {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)inMobiError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitial:didFailToPresentWithError:, ad: %@, error: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial", inMobiError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    if (interstitial == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    } else if (interstitial == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
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
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
    } else if (interstitial == _interstitialAd){
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
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
        [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
    }
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method:userWillLeaveApplicationFromInterstitial:, ad: %@}",TAG, interstitial == _rewardAd ? @"reward" : @"interstitial"];
    NSLog(message);
}

@end
