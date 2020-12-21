//
//  Yodo1MasVungleAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasVungleAdapter.h"
#import <VungleSDK/VungleSDK.h>

#define TAG @"[Yodo1MasVungleAdapter]"

@interface Yodo1MasVungleAdapter()

@end

@implementation Yodo1MasVungleAdapter

- (NSString *)advertCode {
    return @"Vungle";
}

- (NSString *)sdkVersion {
    return @"1.0.0";
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        NSError *error;
        BOOL initSdk = [[VungleSDK sharedSDK] startWithAppId:config.appId error:&error];
        if (initSdk) {
            if (successful != nil) {
                successful(self.advertCode);
            }
            [self updatePrivacy];
            [self loadRewardAdvert];
            [self loadInterstitialAdvert];
            [self loadBannerAdvert];
        } else {
            if (fail != nil) {
                fail(self.advertCode, error);
            }
        }
    }
    
}

- (BOOL)isInitSDK {
    return [[VungleSDK sharedSDK] isInitialized];
}

- (void)updatePrivacy {
    if ([Yodo1Mas sharedInstance].isCCPADoNotSell) {
        [[VungleSDK sharedSDK] updateCCPAStatus:VungleCCPADenied];
    } else {
        [[VungleSDK sharedSDK] updateCCPAStatus:VungleCCPAAccepted];
    }
    if ([Yodo1Mas sharedInstance].isGDPRUserConsent) {
        [[VungleSDK sharedSDK] updateConsentStatus:VungleConsentAccepted consentMessageVersion:@""];
    } else {
        [[VungleSDK sharedSDK] updateConsentStatus:VungleCCPADenied consentMessageVersion:@""];
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.rewardPlacementId];
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    if (self.rewardPlacementId != nil && self.rewardPlacementId.length > 0) {
        
        NSError *error = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.rewardPlacementId error:&error];
        if (!request || error != nil) {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:[NSString stringWithFormat:@"%@: {method: loadRewardAdvert, load failed}", TAG]];
            [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
        }
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        
        if (controller != nil) {
            NSError *error = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:self.rewardPlacementId error:&error];
            if (!show || error != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:[NSString stringWithFormat:@"%@: {method: showRewardAdvert:callback:, show failed}", TAG]];
                [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
            }
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.interstitialPlacementId];
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    if (self.interstitialPlacementId != nil && self.interstitialPlacementId.length > 0) {
        
        NSError *error = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.interstitialPlacementId error:&error];
        if (!request || error != nil) {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:[NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert, load failed}", TAG]];
            [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
        }
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        
        if (controller != nil) {
            NSError *error = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:self.interstitialPlacementId error:&error];
            if (!show || error != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:[NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:callback:, show failed}", TAG]];
                [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
            }
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

@end
