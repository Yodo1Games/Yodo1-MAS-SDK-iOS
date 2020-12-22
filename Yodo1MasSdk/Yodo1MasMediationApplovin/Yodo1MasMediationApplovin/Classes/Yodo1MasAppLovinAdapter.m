//
//  Yodo1MasAppLovinAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAppLovinAdapter.h"
@import  AppLovinSDK;

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
    return self.sdk != nil;
}

- (void)updatePrivacy {
    [ALPrivacySettings setHasUserConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
    [ALPrivacySettings setIsAgeRestrictedUser:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [ALPrivacySettings setDoNotSell:[Yodo1Mas sharedInstance].isCCPADoNotSell];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    if (self.rewardAd == nil && self.rewardPlacementId != nil) {
        self.rewardAd = [MARewardedAd sharedWithAdUnitIdentifier:self.rewardPlacementId];
        self.rewardAd.delegate = self;
    }
    
    if (self.rewardAd != nil) {
        [self.rewardAd loadAd];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        [self.rewardAd showAd];
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialAd != nil && self.interstitialAd.isReady;
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    if (self.interstitialAd == nil && self.interstitialPlacementId != nil) {
        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    
    if (self.interstitialAd != nil) {
        [self.interstitialAd loadAd];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        [self.interstitialAd showAd];
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return self.bannerView != nil;
}

- (void)loadBannerAdvert {
    if (![self isInitSDK]) return;
    if (self.bannerView == nil && self.bannerPlacementId != nil) {
        self.bannerView = [[MAAdView alloc] initWithAdUnitIdentifier:self.bannerPlacementId];
        self.bannerView.delegate = self;
    }
    if (self.bannerView != nil) {
        [self.bannerView loadAd];
    }
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:callback];
    
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
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
    if (self.bannerView != nil) {
        [self.bannerView removeFromSuperview];
    }
}

#pragma mark - MAAdDelegate
- (void)didLoadAd:(MAAd *)ad {
    
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode {
    
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
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:type];
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
    
    [self loadAdvert:type];
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:type];
}

- (void)didClickAd:(MAAd *)ad {
    
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
    
    [self loadAdvert:type];
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:[NSString stringWithFormat:@"Applovin %@", @(errorCode)]];
    [self callbackWithError:error type:type];
}

#pragma mark - MARewardedAdDelegate
- (void)didStartRewardedVideoForAd:(MAAd *)ad {
    
}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {
//    [self loadRewardAdvert];
}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
}

#pragma mark - MAAdViewAdDelegate
- (void)didExpandAd:(MAAd *)ad {
    
}

- (void)didCollapseAd:(MAAd *)ad {
    [self loadBannerAdvert];
}

@end
