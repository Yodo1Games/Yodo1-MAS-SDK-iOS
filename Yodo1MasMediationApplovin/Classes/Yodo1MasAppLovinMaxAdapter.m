//
//  Yodo1MasAppLovinMaxAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAppLovinMaxAdapter.h"
@import  AppLovinSDK;

#define BANNER_TAG 10016

@interface Yodo1MasAppLovinMaxAdapter()<MARewardedAdDelegate, MAAdViewAdDelegate>

@property (nonatomic, strong) ALSdk *sdk;

@property (nonatomic, strong) MARewardedAd *rewardAd;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;
@property (nonatomic, strong) MAAdView *bannerAd;
@property (nonatomic, copy) NSString *currentBannerUnitId;

@end

@implementation Yodo1MasAppLovinMaxAdapter

- (NSString *)advertCode {
    return @"APPLOVIN";
}

- (NSString *)sdkVersion {
    return [ALSdk version];
}

- (NSString *)mediationVersion {
    return @"4.0.2.1";
}

- (BOOL)isMax {
    return YES;
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    if (![self isInitSDK]) {
        self.sdk = [ALSdk shared];
        if ([self isMax]) {
            self.sdk.mediationProvider = @"max";
        }
        
        // Facebook设置
        Class fbAdSettings = NSClassFromString(@"FBAdSettings");
        if (fbAdSettings) {
            SEL sel = NSSelectorFromString(@"setAdvertiserTrackingEnabled:");
            if (sel && [fbAdSettings respondsToSelector:sel]) {
                [fbAdSettings performSelector:sel withObject:@(YES) afterDelay:0];
            }
        }
        
        __weak __typeof(self)weakSelf = self;
        [self.sdk initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
            NSLog(@"%@: {method:ALSdkInitializationCompletionHandler}", self.TAG);
            
            [weakSelf updatePrivacy];
            [weakSelf loadRewardAd];
            [weakSelf loadInterstitialAd];
            [weakSelf loadBannerAd];
            
            if (successful != nil) {
                successful(weakSelf.advertCode);
            }
        }];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return self.sdk != nil;
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [ALPrivacySettings setHasUserConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
    [ALPrivacySettings setIsAgeRestrictedUser:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [ALPrivacySettings setDoNotSell:[Yodo1Mas sharedInstance].isCCPADoNotSell];
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
        self.rewardAd = [MARewardedAd sharedWithAdUnitIdentifier:[self getRewardAdId].adId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSLog(@"%@: {method:loadRewardAd, loading reward ad...}", self.TAG);
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        NSLog(@"%@: {method:showRewardAd, show reward ad...}", self.TAG);
        
        NSString *placement = object != nil ? object[kArgumentPlacement] : nil;
        if ([self isMax] && placement != nil && placement.length > 0) {
            [self.rewardAd showAdForPlacement:placement];
        } else {
            [self.rewardAd showAd];
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
    if ([self getInterstitialAdId]) {
        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:[self getInterstitialAdId].adId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSLog(@"%@: {method:loadInterstitialAd, loading interstitial ad...}", self.TAG);
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        NSLog(@"%@: {method:loadInterstitialAd, show interstitial ad...}", self.TAG);
        
        NSString *placement = object != nil ? object[kArgumentPlacement] : nil;
        if ([self isMax] && placement != nil && placement.length > 0) {
            [self.interstitialAd showAdForPlacement:placement];
        } else {
            [self.interstitialAd showAd];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerAd != nil && [self getBannerAdId] != nil && self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getBannerAdId];
    if (adId != nil && adId.adId != nil && (self.currentBannerUnitId == nil || ![adId.adId isEqualToString:self.currentBannerUnitId])) {
        self.bannerAd = [[MAAdView alloc] initWithAdUnitIdentifier:[self getBannerAdId].adId];
        self.bannerAd.frame = CGRectMake(0, 0, self.adSize.width, self.adSize.height);
        self.bannerAd.delegate = self;
        self.currentBannerUnitId = adId.adId;
    }
    if (self.bannerAd != nil && self.bannerState != Yodo1MasBannerStateLoading) {
        NSLog(@"%@: {method:loadBannerAd, loading banner ad...}", self.TAG);
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:[Yodo1MasAppLovinMaxAdapter getTopViewController]];
        [self.bannerAd loadAd];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSLog(@"%@: {method:showBannerAd:, show banner ad...}", self.TAG);
        
        NSString *placement = object != nil ? object[kArgumentPlacement] : nil;
        if (placement != nil && placement.length > 0) {
            self.bannerAd.placement = placement;
        }
        UIViewController *controller = [Yodo1MasAppLovinMaxAdapter getTopViewController];
        [Yodo1MasBanner showBannerWithTag:BANNER_TAG controller:controller object:object];
        [self.bannerAd startAutoRefresh];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (self.bannerAd != nil) {
        [self.bannerAd stopAutoRefresh];
    }
    if (destroy) {
        self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        self.currentBannerUnitId = nil;
        [self loadBannerAd];
    }
}

#pragma mark - MAAdDelegate
- (void)didLoadAd:(MAAd *)ad {
    NSLog(@"%@: {method:didLoadAd:, ad:%@}", self.TAG, ad.adUnitIdentifier);
    if ([ad.adUnitIdentifier isEqualToString:[self getBannerAdId].adId]) {
        self.bannerState = Yodo1MasBannerStateLoaded;
    }
    if (ad.format == MAAdFormat.rewarded) {
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
    } else if (ad.format == MAAdFormat.interstitial) {
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
    } else if (ad.format == MAAdFormat.banner) {
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode {
    Yodo1MasAdType type;
    if ([adUnitIdentifier isEqualToString:[self getRewardAdId].adId]) {
        type = Yodo1MasAdTypeReward;
        [self nextReward];
    } else if ([adUnitIdentifier isEqualToString:[self getInterstitialAdId].adId]) {
        type = Yodo1MasAdTypeInterstitial;
        [self nextInterstitial];
    } else if ([adUnitIdentifier isEqualToString:[self getBannerAdId].adId]) {
        type = Yodo1MasAdTypeBanner;
        [self nextBanner];
        self.bannerState = Yodo1MasBannerStateNone;
    } else {
        return;
    }

    NSString *message = [NSString stringWithFormat:@"%@: {method:didLoadAd:, ad:%@, error: %@}", self.TAG, adUnitIdentifier, @(errorCode)];
    NSLog(@"%@", message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:type];
    [self loadAdDelayed:type];
}

- (void)didDisplayAd:(MAAd *)ad {
    Yodo1MasAdType type;
    if (ad.format == MAAdFormat.rewarded) {
        type = Yodo1MasAdTypeReward;
    } else if (ad.format == MAAdFormat.interstitial) {
        type = Yodo1MasAdTypeInterstitial;
    } else if (ad.format == MAAdFormat.banner) {
        type = Yodo1MasAdTypeBanner;
    } else {
        return;
    }
    
    NSLog(@"%@: {method:didDisplayAd:, ad:%@}", self.TAG, ad.adUnitIdentifier);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:type];
}

- (void)didHideAd:(MAAd *)ad {
    Yodo1MasAdType type;
    if (ad.format == MAAdFormat.rewarded) {
        type = Yodo1MasAdTypeReward;
    } else if (ad.format == MAAdFormat.interstitial) {
        type = Yodo1MasAdTypeInterstitial;
    } else if (ad.format == MAAdFormat.banner) {
        type = Yodo1MasAdTypeBanner;
        self.bannerState = Yodo1MasBannerStateNone;
    } else {
        return;
    }
    
    NSLog(@"%@: {method:didHideAd:, ad:%@}",self.TAG, ad.adUnitIdentifier);

    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:type];
    [self loadAd:type];
}

- (void)didClickAd:(MAAd *)ad {
    NSLog(@"%@: {method:didClickAd:, ad:%@}", self.TAG, ad.adUnitIdentifier);
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode {
    Yodo1MasAdType type;
    if (ad.format == MAAdFormat.rewarded) {
        type = Yodo1MasAdTypeReward;
        [self nextReward];
    } else if (ad.format == MAAdFormat.interstitial) {
        type = Yodo1MasAdTypeInterstitial;
        [self nextInterstitial];
    } else if (ad.format == MAAdFormat.banner) {
        type = Yodo1MasAdTypeBanner;
        [self nextBanner];
        self.bannerState = Yodo1MasBannerStateNone;
    } else {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didFailToDisplayAd:withErrorCode:, ad:%@, error:%@}", self.TAG, ad.adUnitIdentifier, @(errorCode)];
    NSLog(@"%@", message);

    [self loadAd:type];
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:type];
    [self loadAd:type];
}

#pragma mark - MARewardedAdDelegate
- (void)didStartRewardedVideoForAd:(MAAd *)ad {
    NSLog(@"%@: {method:didStartRewardedVideoForAd:, ad:%@}", self.TAG, ad.adUnitIdentifier);
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {
    NSLog(@"%@: {method:didCompleteRewardedVideoForAd:, ad:%@}", self.TAG, ad.adUnitIdentifier);
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward {
    NSLog(@"%@: {method:didRewardUserForAd:withReward:, ad:%@}", self.TAG, ad.adUnitIdentifier);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - MAAdViewAdDelegate
- (void)didExpandAd:(MAAd *)ad {
    NSLog(@"%@: {method:didExpandAd, ad:%@}", self.TAG, ad.adUnitIdentifier);
}

- (void)didCollapseAd:(MAAd *)ad {
    NSLog(@"%@: {method:didCollapseAd, ad:%@}", self.TAG, ad.adUnitIdentifier);
    self.bannerState = Yodo1MasBannerStateNone;
    [self loadBannerAd];
}

@end
