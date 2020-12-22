//
//  Yodo1MasIronSourceMaxAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasIronSourceMaxAdapter.h"
#import <IronSource/IronSource.h>

#define TAG @"[Yodo1MasIronSourceMaxAdapter]"

@interface Yodo1MasIronSourceMaxAdapter()<ISRewardedVideoDelegate, ISInterstitialDelegate, ISBannerDelegate>

@property (nonatomic, assign) BOOL sdkInit;

@end

@implementation Yodo1MasIronSourceMaxAdapter

- (NSString *)advertCode {
    return @"IronSourceMax";
}

- (NSString *)sdkVersion {
    return [IronSource sdkVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
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
            [self loadRewardAdvert];
            [self loadInterstitialAdvert];
            [self loadBannerAdvert];
            if (successful != nil) {
                successful(self.advertCode);
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",TAG];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
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
- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return [IronSource hasRewardedVideo];
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceMaxAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAdvert:, show reward ad...}", TAG];
            NSLog(message);
            [IronSource showRewardedVideoWithViewController:controller];
        }
    }
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
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidOpen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidOpen}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidClose {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidClose}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
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
- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return [IronSource hasInterstitial];
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert, loading interstitial ad...}", TAG];
    NSLog(message);
    [IronSource loadInterstitial];
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceMaxAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:, show interstitial ad...}", TAG];
            NSLog(message);
            [IronSource showInterstitialWithViewController:controller];
        }
    }
}

#pragma mark - ISInterstitialDelegate
- (void)interstitialDidLoad {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidLoad}", TAG];
    NSLog(message);
}

- (void)interstitialDidFailToLoadWithError:(NSError *)ironSourceError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToLoadWithError:, error: %@}", TAG, ironSourceError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidOpen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidOpen}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidClose {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidClose}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidShow {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidShow}", TAG];
    NSLog(message);
}

- (void)interstitialDidFailToShowWithError:(NSError *)ironSourceError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToShowWithError:, error: %@}", TAG, ironSourceError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)didClickInterstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickInterstitial}", TAG];
    NSLog(message);
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
}

#pragma mark - ISBannerDelegate
- (void)bannerDidLoad:(ISBannerView *)bannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidLoad:, banner: %@}", TAG, bannerView];
    NSLog(message);
}

- (void)bannerDidFailToLoadWithError:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidFailToLoadWithError:, error: %@}", TAG, adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeBanner];
}

- (void)didClickBanner {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickBanner}", TAG];
    NSLog(message);
}

- (void)bannerWillPresentScreen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillPresentScreen}", TAG];
    NSLog(message);
}

- (void)bannerDidDismissScreen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidDismissScreen}", TAG];
    NSLog(message);
}

- (void)bannerWillLeaveApplication {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillLeaveApplication}", TAG];
    NSLog(message);
}

@end
