//
//  Yodo1MasUnityAdsAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasUnityAdsAdapter.h"
@import UnityAds;

#define TAG @"[Yodo1MasUnityAdsAdapter]"

@interface Yodo1MasUnityAdsAdapter()<UnityAdsInitializationDelegate, UnityAdsLoadDelegate, UnityAdsDelegate>

@end

@implementation Yodo1MasUnityAdsAdapter

- (NSString *)advertCode {
    return @"UnityAds";
}

- (NSString *)sdkVersion {
    return [UnityAds getVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [UnityAds removeDelegate:self];
        [UnityAds addDelegate:self];
        [UnityAds initialize:config.appId initializationDelegate:self];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

#pragma mark - UnityAdsInitializationDelegate
- (void)initializationComplete {
    if (self.initSuccessfulCallback != nil) {
        self.initSuccessfulCallback(self.advertCode);
    }
    [self updatePrivacy];
    [self loadRewardAdvert];
    [self loadInterstitialAdvert];
    [self loadBannerAdvert];
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message {
    if (self.initFailCallback != nil) {
        self.initFailCallback(self.advertCode, [NSError errorWithDomain:@"" code:error userInfo:@{}]);
    }
}

- (BOOL)isInitSDK {
    return [UnityAds isInitialized];
}

- (void)updatePrivacy {
    UADSMetaData *metaData = [[UADSMetaData alloc] init];
    [metaData set:@"gdpr.consent" value:@([Yodo1Mas sharedInstance].isGDPRUserConsent)];
    [metaData set:@"privacy.consent" value:@([Yodo1Mas sharedInstance].isCCPADoNotSell)];
    [metaData commit];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardPlacementId != nil && [UnityAds isReady:self.rewardPlacementId];
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    if (self.rewardPlacementId != nil && self.rewardPlacementId.length > 0) {
        [UnityAds load:self.rewardPlacementId loadDelegate:self];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        
        if (controller != nil) {
            [UnityAds show:controller placementId:self.rewardPlacementId];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialPlacementId != nil && [UnityAds isReady:self.interstitialPlacementId];
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    if (self.interstitialPlacementId != nil && self.interstitialPlacementId.length > 0) {
        [UnityAds load:self.interstitialPlacementId loadDelegate:self];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasUnityAdsAdapter getTopViewController];
        
        if (controller != nil) {
            [UnityAds show:controller placementId:self.interstitialPlacementId];
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return NO;
}

- (void)loadBannerAdvert {
    
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        
    }
}

#pragma mark - UnityAdsLoadDelegate
- (void)unityAdsAdLoaded:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@:{method: unityAdsAdLoaded:, placementId: %@}", TAG, placementId];
    NSLog(message);
}

- (void)unityAdsAdFailedToLoad:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@:{method: unityAdsAdFailedToLoad:, placementId: %@}", TAG, placementId];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    if (self.rewardPlacementId != nil && [placementId isEqualToString:self.rewardPlacementId]) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    } else if (self.interstitialPlacementId != nil && [placementId isEqualToString:self.interstitialPlacementId]) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    }
}

#pragma mark - UnityAdsDelegate
- (void)unityAdsReady:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@:{method: unityAdsReady:, placementId: %@}", TAG, placementId];
    NSLog(message);
}

- (void)unityAdsDidError:(UnityAdsError)adError withMessage:(NSString *)adMessage {
    NSString *message = [NSString stringWithFormat:@"%@:{method: unityAdsDidError:withMessage:, error: %@, message: %@}", TAG, @(adError), adMessage];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSString *message = [NSString stringWithFormat:@"%@:{method: unityAdsDidStart:, placementId: %@}", TAG, placementId];
    NSLog(message);
    
    if (self.rewardPlacementId != nil && [placementId isEqualToString:self.rewardPlacementId]) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
    } else if (self.interstitialPlacementId != nil && [placementId isEqualToString:self.interstitialPlacementId]) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId
          withFinishState:(UnityAdsFinishState)state {
    NSString *message = [NSString stringWithFormat:@"%@:{method: unityAdsDidFinish:, placementId: %@, state: %@}", TAG, placementId, @(state)];
    NSLog(message);
    
    switch (state) {
        case kUnityAdsFinishStateError: {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
            if (self.rewardPlacementId != nil && [placementId isEqualToString:self.rewardPlacementId]) {
                [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
            } else if (self.interstitialPlacementId != nil && [placementId isEqualToString:self.interstitialPlacementId]) {
                [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
            }
            break;
        }
        default: {
            if (self.rewardPlacementId != nil && [placementId isEqualToString:self.rewardPlacementId]) {
                [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
            } else if (self.interstitialPlacementId != nil && [placementId isEqualToString:self.interstitialPlacementId]) {
                [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
            }
            break;
        }
    }
}

@end
