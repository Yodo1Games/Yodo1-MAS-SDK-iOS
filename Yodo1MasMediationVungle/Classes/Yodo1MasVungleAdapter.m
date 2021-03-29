//
//  Yodo1MasVungleAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasVungleAdapter.h"
#import <VungleSDK/VungleSDK.h>

#define BANNER_TAG 10008

@interface Yodo1MasVungleAdapter()

@property (nonatomic, strong) UIView *bannerAd;

@end

@implementation Yodo1MasVungleAdapter

- (NSString *)advertCode {
    return @"vungle";
}

- (NSString *)sdkVersion {
    return @"6.8.1";
}

- (NSString *)mediationVersion {
    return @"4.0.4";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        
        if (config.appId != nil && config.appId.length > 0) {
            NSError *adError;
            BOOL initSdk = [[VungleSDK sharedSDK] startWithAppId:config.appId error:&adError];
            NSString *message = [NSString stringWithFormat:@"%@:{method:initWithConfig:, error: %@}", self.TAG, adError];
            
            NSLog(@"%@", message);
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
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",self.TAG];
            NSLog(@"%@", message);
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
        [[VungleSDK sharedSDK] updateConsentStatus:VungleConsentDenied consentMessageVersion:@""];
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return [self getRewardAdId] != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:[self getRewardAdId].adId];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if ([self getRewardAdId] != nil) {
        NSLog(@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG);
        
        NSError *adError = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:[self getRewardAdId].adId error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, error: %@}", self.TAG, adError];
            NSLog(@"%@", message);
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeReward];
            [self nextReward];
            [self loadRewardAdDelayed];
        }else{
            [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
        }
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@: {method: showRewardAd:, show reward ad...}", self.TAG);
            
            NSError *adError = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:[self getRewardAdId].adId error:&adError];
            if (!show || adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd:callback:, error: %@}", self.TAG, adError];
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
                [self callbackWithError:error type:Yodo1MasAdTypeReward];
                [self nextReward];
                [self loadRewardAd];
            } else {
                [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
                [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
            }
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [self getInterstitialAdId] != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:[self getInterstitialAdId].adId];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if ([self getInterstitialAdId] != nil) {
        
        NSLog(@"%@: {method: loadInterstitialAd, loading interstitial ad...}", self.TAG);
        
        NSError *adError = nil;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:[self getInterstitialAdId].adId error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, error:%@}", self.TAG, adError];
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
            [self nextInterstitial];
            [self loadInterstitialAdDelayed];
        }else{
            [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
        }
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@: {method: showInterstitialAd:, show interstitial ad...}", self.TAG);
            
            NSError *adError = nil;
            BOOL show = [[VungleSDK sharedSDK] playAd:controller options:nil placementID:[self getInterstitialAdId].adId error:&adError];
            if (!show || adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:callback:, error: %@}", self.TAG, adError];
                NSLog(@"%@", message);
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
                [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
                [self nextInterstitial];
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
    return [self getBannerAdId] != nil && [[VungleSDK sharedSDK] isAdCachedForPlacementID:[self getBannerAdId].adId withSize:VungleAdSizeBanner] && self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (self.bannerAd == nil) {
        self.bannerAd = [[UIView alloc] init];
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:[Yodo1MasVungleAdapter getTopViewController]];
    }
    
    Yodo1MasAdId *adId = [self getBannerAdId];
    if (adId != nil && adId.adId != nil) {
        NSLog(@"%@: {method:loadBannerAd:, loading banner ad...}", self.TAG);
        NSError *adError;
        BOOL request = [[VungleSDK sharedSDK] loadPlacementWithID:[self getBannerAdId].adId withSize:VungleAdSizeBanner error:&adError];
        if (!request || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: loadBannerAd, error: %@}", self.TAG, adError];
            NSLog(@"%@", message);
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeBanner];
            [self nextBanner];
            [self loadRewardAdDelayed];
        }else{
            [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
        }
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSLog(@"%@: {method:showBannerAd:align:, show banner ad...}", self.TAG);
        NSError *adError;
        BOOL show = [[VungleSDK sharedSDK] addAdViewToView:self.bannerAd withOptions:nil placementID:[self getBannerAdId].adId error:&adError];

        if (!show || adError != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:callback:, error: %@}", self.TAG, adError];
            NSLog(@"%@", message);
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
            [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
            [self nextBanner];
            [self loadBannerAdDelayed];
        } else {
            UIViewController *controller = [Yodo1MasVungleAdapter getTopViewController];
            [Yodo1MasBanner showBanner:self.bannerAd tag:BANNER_TAG controller:controller object:object];
            [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
        }
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        if ([self getBannerAdId] != nil) {
            [[VungleSDK sharedSDK] finishDisplayingAd:[self getBannerAdId].adId];
        }
        self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}

@end
