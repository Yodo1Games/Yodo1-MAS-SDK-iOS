//
//  Yodo1MasAppLovinAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAppLovinAdapter.h"
@import  AppLovinSDK;

#define TAG @"[Yodo1MasAppLovinAdapter]"

@interface Yodo1MasAppLovinAdapter()<MARewardedAdDelegate, MAAdViewAdDelegate>

@property (nonatomic, strong) ALSdk *sdk;

@property (nonatomic, strong) MARewardedAd *rewardAd;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;
@property (nonatomic, strong) MAAdView *bannerAd;

@end

@implementation Yodo1MasAppLovinAdapter

- (NSString *)advertCode {
    return @"AppLovin";
}

- (NSString *)sdkVersion {
    return [ALSdk version];
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    if (![self isInitSDK]) {
        self.sdk = [ALSdk shared];
        if ([self isMax]) {
            self.sdk.mediationProvider = @"max";
        }
        __weak __typeof(self)weakSelf = self;
        [self.sdk initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
            
            NSString *message = [NSString stringWithFormat:@"%@: {method:ALSdkInitializationCompletionHandler}", TAG];
            NSLog(message);
            
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
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [MARewardedAd sharedWithAdUnitIdentifier:self.rewardPlacementId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAd, loading reward ad...}", TAG];
        NSLog(message);
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAd, show reward ad...}", TAG];
        NSLog(message);
        
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
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, loading interstitial ad...}", TAG];
        NSLog(message);
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAd, show interstitial ad...}", TAG];
        NSLog(message);
        
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
    return self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    if (self.bannerAd == nil && self.bannerPlacementId != nil) {
        self.bannerAd = [[MAAdView alloc] initWithAdUnitIdentifier:self.bannerPlacementId];
        self.bannerAd.delegate = self;
    }
    if (self.bannerAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd, loading banner ad...}", TAG];
        NSLog(message);
        [self.bannerAd loadAd];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", TAG];
        NSLog(message);
        
        NSString *placement = object != nil ? object[kArgumentPlacement] : nil;
        if (placement != nil && placement.length > 0) {
            self.bannerAd.placement = placement;
        }
        
        UIViewController *controller = [Yodo1MasAppLovinAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
    }
}

- (void)dismissBannerAd {
    [super dismissBannerAd];
    [Yodo1MasBanner removeBanner:self.bannerAd];
    self.bannerAd = nil;
}

#pragma mark - MAAdDelegate
- (void)didLoadAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didLoadAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode {
    Yodo1MasAdType type;
    if (adUnitIdentifier == self.rewardPlacementId) {
        type = Yodo1MasAdTypeReward;
    } else if (adUnitIdentifier == self.interstitialPlacementId) {
        type = Yodo1MasAdTypeInterstitial;
    } else if (adUnitIdentifier == self.bannerPlacementId) {
        type = Yodo1MasAdTypeBanner;
    } else {
        return;
    }

    NSString *message = [NSString stringWithFormat:@"%@: {method:didLoadAd:, ad:%@, error: %@}", TAG, adUnitIdentifier, @(errorCode)];
    NSLog(message);
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
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didDisplayAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
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
    } else {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didHideAd:, ad:%@}",TAG, ad.adUnitIdentifier];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:type];
    [self loadAd:type];
}

- (void)didClickAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didClickAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode {
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
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didFailToDisplayAd:withErrorCode:, ad:%@, error:%@}", TAG, ad.adUnitIdentifier, @(errorCode)];
    NSLog(message);

    [self loadAd:type];
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:type];
    [self loadAd:type];
}

#pragma mark - MARewardedAdDelegate
- (void)didStartRewardedVideoForAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didStartRewardedVideoForAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didCompleteRewardedVideoForAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didRewardUserForAd:withReward:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - MAAdViewAdDelegate
- (void)didExpandAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didExpandAd, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didCollapseAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didCollapseAd, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
    [self loadBannerAd];
}

@end
