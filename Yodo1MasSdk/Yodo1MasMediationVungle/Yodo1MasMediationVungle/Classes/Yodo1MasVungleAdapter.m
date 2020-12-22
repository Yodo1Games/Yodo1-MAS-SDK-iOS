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
        
        if (config.appId != nil && config.appId.length > 0) {
            NSError *adError;
            BOOL initSdk = [[VungleSDK sharedSDK] startWithAppId:config.appId error:&adError];
            NSString *message = [NSString stringWithFormat:@"%@:{method:initWithConfig:, error: %@}", TAG, adError];
            
            NSLog(message);
            if (initSdk && adError == nil) {
                [self updatePrivacy];
                [self loadRewardAdvert];
                [self loadInterstitialAdvert];
                [self loadBannerAdvert];
                
                if (successful != nil) {
                    successful(self.advertCode);
                }
            } else {
                if (fail != nil) {
                    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
                    fail(self.advertCode, error);
                }
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}"];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
                fail(self.advertCode, error);
            }
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return [[VungleSDK sharedSDK] isInitialized];
}

- (void)updatePrivacy {
    [super updatePrivacy];
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
    [super isRewardAdvertLoaded];
    return self.rewardPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.rewardPlacementId];
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    if (self.rewardPlacementId != nil && self.rewardPlacementId.length > 0) {
        NSLog([NSString stringWithFormat:@"%@: {method: loadRewardAdvert, loading reward ad...}", TAG]);
        
        NSError *adError = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.rewardPlacementId error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAdvert, error: %@}", TAG, adError];
            NSLog(message);
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
            [self loadRewardAdvertDelayed];
        }
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        if (controller != nil) {
            NSLog([NSString stringWithFormat:@"%@: {method: showRewardAdvert:, show reward ad...}", TAG]);
            
            NSError *adError = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:self.rewardPlacementId error:&adError];
            if (!show || adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAdvert:callback:, error: %@}", TAG, adError];
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
                [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
                [self loadRewardAdvert];
            }
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return self.interstitialPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.interstitialPlacementId];
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    if (self.interstitialPlacementId != nil && self.interstitialPlacementId.length > 0) {
        
        NSLog([NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert, loading interstitial ad...}", TAG]);
        
        NSError *adError = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.interstitialPlacementId error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert, error:%@}", TAG, adError];
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
            [self loadInterstitialAdvertDelayed];
        }
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        if (controller != nil) {
            NSLog([NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:, show interstitial ad...}", TAG]);
            
            NSError *adError = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:self.interstitialPlacementId error:&adError];
            if (!show || adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:callback:, error: %@}", TAG, adError];
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
                [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
                [self loadInterstitialAdvert];
            }
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
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        
    }
}

@end
