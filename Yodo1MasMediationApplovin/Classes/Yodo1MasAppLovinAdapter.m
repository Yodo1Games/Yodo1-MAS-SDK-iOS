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
@property (nonatomic, strong) MAAdView *bannerView;

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
            [weakSelf loadRewardAdvert];
            [weakSelf loadInterstitialAdvert];
            [weakSelf loadBannerAdvert];
            
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
- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [MARewardedAd sharedWithAdUnitIdentifier:self.rewardPlacementId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadRewardAdvert, loading reward ad...}", TAG];
        NSLog(message);
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showRewardAdvert, show reward ad...}", TAG];
        NSLog(message);
        [self.rewardAd showAd];
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
        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAdvert, loading interstitial ad...}", TAG];
        NSLog(message);
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAdvert, show interstitial ad...}", TAG];
        NSLog(message);
        [self.interstitialAd showAd];
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    [super isBannerAdvertLoaded];
    return self.bannerView != nil;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
    if (![self isInitSDK]) return;
    if (self.bannerView == nil && self.bannerPlacementId != nil) {
        self.bannerView = [[MAAdView alloc] initWithAdUnitIdentifier:self.bannerPlacementId];
        self.bannerView.delegate = self;
    }
    if (self.bannerView != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAdvert, loading banner ad...}", TAG];
        NSLog(message);
        [self.bannerView loadAd];
    }
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:callback];
    
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAdvert:, show banner ad...}", TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasAppLovinAdapter getTopViewController];
        if (controller != nil) {
            self.bannerView.frame = CGRectMake(0, controller.view.bounds.size.height - 50, controller.view.bounds.size.width, 50);
            [controller.view addSubview:self.bannerView];
        } else {
            UIWindow *window = [Yodo1MasAppLovinAdapter getTopWindow];
            self.bannerView.frame = CGRectMake(0, window.bounds.size.height - 50, window.bounds.size.width, 50);
            [window addSubview:self.bannerView];
        }
    }
}

- (void)dismissBannerAdvert {
    [super dismissBannerAdvert];
    if (self.bannerView != nil) {
        [self.bannerView removeFromSuperview];
    }
}

#pragma mark - MAAdDelegate
- (void)didLoadAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didLoadAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode {
    Yodo1MasAdvertType type;
    if (adUnitIdentifier == self.rewardPlacementId) {
        type = Yodo1MasAdvertTypeReward;
    } else if (adUnitIdentifier == self.interstitialPlacementId) {
        type = Yodo1MasAdvertTypeInterstitial;
    } else if (adUnitIdentifier == self.bannerPlacementId) {
        type = Yodo1MasAdvertTypeBanner;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didLoadAd:, ad:%@, error: %@}", TAG, adUnitIdentifier, @(errorCode)];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    [self callbackWithError:error type:type];
}

- (void)didDisplayAd:(MAAd *)ad {
    Yodo1MasAdvertType type;
    if (ad.format == MAAdFormat.rewarded) {
        type = Yodo1MasAdvertTypeReward;
    } else if (ad.format == MAAdFormat.interstitial) {
        type = Yodo1MasAdvertTypeInterstitial;
    } else if (ad.format == MAAdFormat.banner) {
        type = Yodo1MasAdvertTypeBanner;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didDisplayAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:type];
    [self loadAdvertDelayed:type];
}

- (void)didHideAd:(MAAd *)ad {
    Yodo1MasAdvertType type;
    if (ad.format == MAAdFormat.rewarded) {
        type = Yodo1MasAdvertTypeReward;
    } else if (ad.format == MAAdFormat.interstitial) {
        type = Yodo1MasAdvertTypeInterstitial;
    } else if (ad.format == MAAdFormat.banner) {
        type = Yodo1MasAdvertTypeBanner;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didHideAd:, ad:%@}",TAG, ad.adUnitIdentifier];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:type];
    [self loadAdvert:type];
}

- (void)didClickAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didClickAd:, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode {
    Yodo1MasAdvertType type;
    if (ad.format == MAAdFormat.rewarded) {
        type = Yodo1MasAdvertTypeReward;
    } else if (ad.format == MAAdFormat.interstitial) {
        type = Yodo1MasAdvertTypeInterstitial;
    } else if (ad.format == MAAdFormat.banner) {
        type = Yodo1MasAdvertTypeBanner;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:didFailToDisplayAd:withErrorCode:, ad:%@, error:%@}", TAG, ad.adUnitIdentifier, @(errorCode)];
    NSLog(message);
    
    [self loadAdvert:type];
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:type];
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
    
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
}

#pragma mark - MAAdViewAdDelegate
- (void)didExpandAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didExpandAd, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
}

- (void)didCollapseAd:(MAAd *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didCollapseAd, ad:%@}", TAG, ad.adUnitIdentifier];
    NSLog(message);
    [self loadBannerAdvert];
}

@end
