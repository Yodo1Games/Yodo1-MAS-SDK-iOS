//
//  Yodo1MasInMobiAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasInMobiAdapter.h"
@import InMobiSDK;

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
        self.sdkInit = YES;
        __weak __typeof(self)weakSelf = self;
        [IMSdk setLogLevel:kIMSDKLogLevelDebug];
        [IMSdk initWithAccountID:config.appId consentDictionary:nil andCompletionHandler:^(NSError * _Nullable error) {
            if (successful != nil) {
                successful(weakSelf.advertCode);
            }
            [weakSelf updatePrivacy];
            [weakSelf loadRewardAdvert];
            [weakSelf loadInterstitialAdvert];
            [weakSelf loadBannerAdvert];
        }];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    return self.sdkInit;
}

- (void)updatePrivacy {
    if ([Yodo1Mas sharedInstance].isGDPRUserConsent) {
        [IMSdk updateGDPRConsent:@{IM_GDPR_CONSENT_AVAILABLE : @"true", @"gdpr" : @1}];
    } else {
        [IMSdk updateGDPRConsent:@{IM_GDPR_CONSENT_AVAILABLE : @"false", @"gdpr" : @0}];
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [[IMInterstitial alloc] initWithPlacementId:[self.rewardPlacementId longLongValue]];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        [self.rewardAd load];
    }
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        if (controller == nil) {
            controller == [Yodo1MasInMobiAdapter getTopViewController];
        }
        if (controller != nil) {
            [self.rewardAd showFromViewController:controller];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialAd != nil && self.interstitialAd.isReady;
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[IMInterstitial alloc] initWithPlacementId:[self.interstitialPlacementId longLongValue]];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        [self.interstitialAd load];
    }
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        if (controller == nil) {
            controller == [Yodo1MasInMobiAdapter getTopViewController];
        }
        if (controller != nil) {
            [self.interstitialAd showFromViewController:controller];
        }
    }
}

#pragma mark - 横幅广告

#pragma mark - IMInterstitialDelegate
- (void)interstitial:(IMInterstitial*)interstitial didReceiveWithMetaInfo:(IMAdMetaInfo*)metaInfo {
    
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToReceiveWithError:(NSError*)error {
    
}

- (void)interstitial:(IMInterstitial*)interstitial gotSignals:(NSData*)signals {
    
}

- (void)interstitial:(IMInterstitial*)interstitial failedToGetSignalsWithError:(IMRequestStatus*)status {
    
}

- (void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    
}

- (void)interstitialWillPresent:(IMInterstitial*)interstitial {
    
}

- (void)interstitialDidPresent:(IMInterstitial*)interstitial {
    if (interstitial == self.rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
    } else {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)inMobiError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:inMobiError.localizedDescription];
    if (interstitial == self.rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    } else {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)interstitialWillDismiss:(IMInterstitial*)interstitial {
    
}

- (void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    if (interstitial == self.rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
    } else {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    
}

- (void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    if (interstitial == self.rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
    }
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial {
    
}

@end
