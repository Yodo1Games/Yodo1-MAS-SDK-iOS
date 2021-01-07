//
//  Yodo1MasAdMobAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdMobAdapter.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define TAG @"[Yodo1MasAdMobAdapter]"

@interface Yodo1MasAdMobAdapter()<GADRewardedAdDelegate, GADInterstitialDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) GADMobileAds *sdk;
@property (nonatomic, strong) GADRewardedAd *rewardAd;
@property (nonatomic, strong) GADInterstitial *interstitialAd;
@property (nonatomic, strong) GADBannerView *bannerAd;

@end

@implementation Yodo1MasAdMobAdapter

- (NSString *)advertCode {
    return @"AdMob";
}

- (NSString *)sdkVersion {
    return [GADMobileAds sharedInstance].sdkVersion;
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (self.sdk == nil) {
        self.sdk = [GADMobileAds sharedInstance];
    }
    if (![self isInitSDK]) {
        if (!self.isMax) {
            [self.sdk disableMediationInitialization];
        }
        __weak __typeof(self)weakSelf = self;
        [self.sdk startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
            
            [weakSelf updatePrivacy];
            [weakSelf loadRewardAdvert];
            [weakSelf loadInterstitialAdvert];
            [weakSelf loadBannerAdvert];
            
            if (successful != nil) {
                successful(weakSelf.advertCode);
            }
            
            NSString *message = [NSString stringWithFormat:@"%@: {method: GADInitializationCompletionHandler, status: %@}", TAG, status];
            NSLog(message);
        }];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    if (self.sdk == nil) {
        return NO;
    } else {
        NSDictionary<NSString *, GADAdapterStatus *> *adapters = self.sdk.initializationStatus.adapterStatusesByClassName;
        GADAdapterStatus *status = adapters[NSStringFromClass([GADMobileAds class])];
        return status != nil && status.state == GADAdapterInitializationStateReady;
    }
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [[NSUserDefaults standardUserDefaults] setBool:[Yodo1Mas sharedInstance].isGDPRUserConsent forKey:@"gad_npa"];
    [[GADMobileAds sharedInstance].requestConfiguration tagForChildDirectedTreatment:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [[GADMobileAds sharedInstance].requestConfiguration tagForUnderAgeOfConsent:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [[NSUserDefaults standardUserDefaults] setBool:[Yodo1Mas sharedInstance].isCCPADoNotSell forKey:@"gad_rdp"];
}


#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return self.rewardAd != nil && self.rewardAd.isReady;
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    
    if (self.rewardPlacementId != nil) {
        self.rewardAd = [[GADRewardedAd alloc] initWithAdUnitID:self.rewardPlacementId];
    }
    
    if (self.rewardAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAdvert, loading reward ad...}", TAG];
        NSLog(message);
        
        __weak __typeof(self)weakSelf = self;
        [self.rewardAd loadRequest:[GADRequest request] completionHandler:^(GADRequestError * _Nullable adError) {
            if (adError != nil) {
                NSString *message = [NSString stringWithFormat:@"%@:{method: GADRewardedAdLoadCompletionHandler, error: %@}", TAG, adError];
                NSLog(message);

                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
                [weakSelf callbackWithError:error type:Yodo1MasAdTypeReward];
                [weakSelf loadRewardAdvertDelayed];
            }
        }];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@:{method: showRewardAd, show reward ad...}", TAG];
            NSLog(message);
            [self.rewardAd presentFromRootViewController:controller delegate:self];
        }
    }
}

- (void)dismissRewardAdvert {
    
}

#pragma mark - GADRewardedAdDelegate
- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
didFailToPresentWithError:(nonnull NSError *)adMobError {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:didFailToPresentWithError:, reward:%@, error: %@}", TAG, rewardedAd.adUnitID, adMobError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedAdDidPresent:(nonnull GADRewardedAd *)rewardedAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidPresent:, reward: %@}", TAG, rewardedAd.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedAdDidDismiss:(nonnull GADRewardedAd *)rewardedAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidDismiss:, reward: %@}", TAG, rewardedAd.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
 userDidEarnReward:(nonnull GADAdReward *)reward {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:userDidEarnReward:, reward: %@}", TAG, rewardedAd.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return self.interstitialAd != nil && self.interstitialAd.isReady;
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    
    if (self.interstitialPlacementId != nil) {
        self.interstitialAd = [[GADInterstitial alloc] initWithAdUnitID:self.interstitialPlacementId];
        self.interstitialAd.delegate = self;
    }
    if (self.interstitialAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadInterstitialAdvert, loading interstitial ad...}", TAG];
        NSLog(message);
        [self.interstitialAd loadRequest:[GADRequest request]];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAdvert:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", TAG];
            NSLog(message);
            [self.interstitialAd presentFromRootViewController:controller];
        }
    }
}

- (void)dismissInterstitialAdvert {
    
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidReceiveAd, ad: %@}", TAG, ad.adUnitID];
    NSLog(message);
}

- (void)interstitial:(nonnull GADInterstitial *)ad
didFailToReceiveAdWithError:(nonnull GADRequestError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidReceiveAd:, ad: %@, error: %@}", TAG, ad.adUnitID, adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialWillPresentScreen:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidReceiveAd:, ad: %@}", TAG, ad.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidFailToPresentScreen:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidFailToPresentScreen:, ad: %@, show interstitial ad failed}", TAG, ad.adUnitID];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialDidDismissScreen:(nonnull GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialDidDismissScreen:, ad: %@}", TAG, ad.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSString *message = [NSString stringWithFormat:@"%@: {method:interstitialWillDismissScreen:, ad: %@}", TAG, ad.adUnitID];
    NSLog(message);
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    [super isBannerAdvertLoaded];
    return self.bannerAd != nil;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
    if (![self isInitSDK]) return;
    if (self.bannerAd == nil && self.bannerPlacementId != nil) {
        self.bannerAd == [[GADBannerView alloc]
                            initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerAd.adUnitID = self.bannerPlacementId;
        self.bannerAd.delegate = self;
    }
    if (self.bannerAd != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAdvert:, loading banner ad...}", TAG];
        NSLog(message);
        [self.bannerAd loadRequest:[GADRequest request]];
    }
}

- (void)showBannerAdvert:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [self showBannerAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", TAG];
        NSLog(message);
        
        UIViewController *controller = [Yodo1MasAdMobAdapter getTopViewController];
        if (controller != nil) {
            self.bannerAd.rootViewController = controller;
        }
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
    }
}

- (void)dismissBannerAdvert {
    [super dismissBannerAdvert];
    [Yodo1MasBanner removeBanner:self.bannerAd];
    self.bannerAd = nil;
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidReceiveAd:, banner: %@}", TAG, bannerView.adUnitID];
    NSLog(message);
}

- (void)adView:(nonnull GADBannerView *)bannerView
didFailToReceiveAdWithError:(nonnull GADRequestError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adView:didFailToReceiveAdWithError:, banner: %@, error: %@}", TAG, bannerView.adUnitID, adError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self loadBannerAdvertDelayed];
}

- (void)adViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewWillPresentScreen:, banner: %@}", TAG, bannerView.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)adViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adViewDidDismissScreen:, banner: %@}", TAG, bannerView.adUnitID];
    NSLog(message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAdvert];
}

@end
