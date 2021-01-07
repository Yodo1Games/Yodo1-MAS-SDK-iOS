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

@property (nonatomic, strong) UIView *bannerAd;

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
                [self loadRewardAd];
                [self loadInterstitialAd];
                [self loadBannerAd];
                
                if (successful != nil) {
                    successful(self.advertCode);
                }
            } else {
                if (fail != nil) {
                    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
                    fail(self.advertCode, error);
                }
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",TAG];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
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
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return self.rewardPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.rewardPlacementId];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if (self.rewardPlacementId != nil && self.rewardPlacementId.length > 0) {
        NSLog([NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", TAG]);
        
        NSError *adError = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.rewardPlacementId error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, error: %@}", TAG, adError];
            NSLog(message);
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeReward];
            [self loadRewardAdDelayed];
        }
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        if (controller != nil) {
            NSLog([NSString stringWithFormat:@"%@: {method: showRewardAd:, show reward ad...}", TAG]);
            
            NSError *adError = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:self.rewardPlacementId error:&adError];
            if (!show || adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd:callback:, error: %@}", TAG, adError];
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
                [self callbackWithError:error type:Yodo1MasAdTypeReward];
                [self loadRewardAd];
            } else {
                [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
            }
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return self.interstitialPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.interstitialPlacementId];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if (self.interstitialPlacementId != nil && self.interstitialPlacementId.length > 0) {
        
        NSLog([NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", TAG]);
        
        NSError *adError = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.interstitialPlacementId error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, error:%@}", TAG, adError];
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
            [self loadInterstitialAdDelayed];
        }
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        if (controller != nil) {
            NSLog([NSString stringWithFormat:@"%@: {method: showInterstitialAd:, show interstitial ad...}", TAG]);
            
            NSError *adError = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:self.interstitialPlacementId error:&adError];
            if (!show || adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:callback:, error: %@}", TAG, adError];
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
                [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
                [self loadInterstitialAd];
            } else {
                [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
            }
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerPlacementId != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.bannerPlacementId withSize:VungleAdSizeBanner] && self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (self.bannerAd == nil) {
        self.bannerAd = [[UIView alloc] init];
    }
    if (self.bannerPlacementId != nil && self.bannerPlacementId.length > 0) {
        NSLog([NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}", TAG]);
        NSError *adError;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:self.bannerPlacementId withSize:VungleAdSizeBanner error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadBannerAd, error: %@}", TAG, adError];
            NSLog(message);
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeBanner];
            [self loadRewardAdDelayed];
        }
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSLog([NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}", TAG]);
        NSError *adError;
        BOOL show = [[VungleSDK sharedSDK] addAdViewToView:self.bannerAd withOptions:nil placementID:self.bannerPlacementId error:&adError];

        if (!show || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:callback:, error: %@}", TAG, adError];
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
            [self loadBannerAd];
        } else {
            UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
            [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
            [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
        }
    }
}

- (void)dismissBannerAd {
    [super dismissBannerAd];
    [Yodo1MasBanner removeBanner:self.bannerAd];
    if (self.bannerPlacementId != nil) {
        [[VungleSDK sharedSDK] finishDisplayingAd:self.bannerPlacementId];
    }
    self.bannerAd = nil;
    [self loadBannerAd];
}

@end
