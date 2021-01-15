//
//  Yodo1MasIronSourceMaxAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasIronSourceMaxAdapter.h"
#import <IronSource/IronSource.h>

#define TAG @"[Yodo1MasIronSourceMaxAdapter]"

@interface Yodo1MasIronSourceMaxAdapter () <ISRewardedVideoDelegate, ISInterstitialDelegate, ISBannerDelegate>

@property(nonatomic, assign) BOOL sdkInit;
@property(nonatomic, strong) ISBannerView *bannerAd;

@end

@implementation Yodo1MasIronSourceMaxAdapter

- (NSString *)advertCode {
    return @"IronSourceMax";
}

- (NSString *)sdkVersion {
    return [IronSource sdkVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.6-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];

    if (![self isInitSDK]) {
        if (config.appId != nil && config.appId.length > 0) {
            self.sdkInit = YES;
            [IronSource setRewardedVideoDelegate:self];
            [IronSource setInterstitialDelegate:self];
            [IronSource setBannerDelegate:self];
            [IronSource initWithAppKey:config.appId adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_BANNER]];

            [self updatePrivacy];
            [self loadRewardAd];
            [self loadInterstitialAd];
            [self loadBannerAd];
            if (successful != nil) {
                successful(self.advertCode);
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}", TAG];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
                fail(self.advertCode, error);
            }
        }
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return self.sdkInit;
}

#pragma mark - 激励广告

- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return [IronSource hasRewardedVideo];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceMaxAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd:, show reward ad...}", TAG];
            NSLog(message);
            
            NSString *placement = object != nil ? object[kArgumentPlacement] : nil;
            if (placement != nil && placement.length > 0) {
                [IronSource showInterstitialWithViewController:controller placement:placement];
            } else {
                [IronSource showRewardedVideoWithViewController:controller];
            }
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - ISRewardedVideoDelegate

- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoHasChangedAvailability:, available: %@}", TAG, @(available)];
    NSLog(message);
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didReceiveRewardForPlacement:, placement: %@}", TAG, placementInfo.placementName];
    NSLog(message);
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)ironSourceError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidFailToShowWithError:, error: %@}", TAG, ironSourceError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedVideoDidOpen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidOpen}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoDidClose {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidClose}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedVideoDidStart {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidStart}", TAG];
    NSLog(message);
}

- (void)rewardedVideoDidEnd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidEnd}", TAG];
    NSLog(message);
}

- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickRewardedVideo:, placement: %@}", TAG, placementInfo.placementName];
    NSLog(message);
}

#pragma mark - 插屏广告

- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [IronSource hasInterstitial];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", TAG];
    NSLog(message);
    [IronSource loadInterstitial];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceMaxAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:, show interstitial ad...}", TAG];
            NSLog(message);
            NSString *placement = object != nil ? object[kArgumentPlacement] : nil;
            if (placement != nil && placement.length > 0) {
                [IronSource showInterstitialWithViewController:controller placement:placement];
            } else {
                [IronSource showInterstitialWithViewController:controller];
            }
            
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - ISInterstitialDelegate

- (void)interstitialDidLoad {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidLoad}", TAG];
    NSLog(message);
}

- (void)interstitialDidFailToLoadWithError:(NSError *)ironSourceError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToLoadWithError:, error: %@}", TAG, ironSourceError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialDidOpen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidOpen}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidClose {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidClose}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAd];
}

- (void)interstitialDidShow {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidShow}", TAG];
    NSLog(message);
}

- (void)interstitialDidFailToShowWithError:(NSError *)ironSourceError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToShowWithError:, error: %@}", TAG, ironSourceError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    [self nextInterstitial];
    [self loadInterstitialAd];
}

- (void)didClickInterstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickInterstitial}", TAG];
    NSLog(message);
}

#pragma mark - 横幅广告

- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return [self getBannerAdId] != nil && self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if ([self getBannerAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAd:, loading banner ad...}", TAG];
        NSLog(message);
        [IronSource loadBannerWithViewController:[Yodo1MasIronSourceMaxAdapter getTopViewController] size:ISBannerSize_BANNER placement:[self getBannerAdId].adId];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}", TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasIronSourceMaxAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
    }
}

- (void)dismissBannerAd {
    [super dismissBannerAd];
    if (self.bannerAd != nil) {
        [IronSource destroyBanner:self.bannerAd];
        [Yodo1MasBanner removeBanner:self.bannerAd];
    }
    self.bannerAd = nil;
}

#pragma mark - ISBannerDelegate

- (void)bannerDidLoad:(ISBannerView *)bannerView {
    self.bannerAd = bannerView;
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidLoad:, banner: %@}", TAG, bannerView];
    NSLog(message);
}

- (void)bannerDidFailToLoadWithError:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidFailToLoadWithError:, error: %@}", TAG, adError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)didClickBanner {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickBanner}", TAG];
    NSLog(message);
}

- (void)bannerWillPresentScreen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillPresentScreen}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)bannerDidDismissScreen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidDismissScreen}", TAG];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

- (void)bannerWillLeaveApplication {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillLeaveApplication}", TAG];
    NSLog(message);
}

@end
