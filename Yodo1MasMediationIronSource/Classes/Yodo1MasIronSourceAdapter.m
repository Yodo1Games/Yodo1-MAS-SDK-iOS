//
//  Yodo1MasIronSourceAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasIronSourceAdapter.h"
#import <IronSource/IronSource.h>

#define TAG @"[Yodo1MasIronSourceAdapter]"

@interface Yodo1MasIronSourceAdapter () <ISDemandOnlyRewardedVideoDelegate, ISDemandOnlyInterstitialDelegate, ISBannerDelegate>

@property(nonatomic, assign) BOOL sdkInit;
@property(nonatomic, strong) ISBannerView *bannerAd;

@end

@implementation Yodo1MasIronSourceAdapter

- (NSString *)advertCode {
    return @"IronSource";
}

- (NSString *)sdkVersion {
    return [IronSource sdkVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.4-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];

    if (![self isInitSDK]) {
        if (config.appId != nil && config.appId.length > 0) {
            self.sdkInit = YES;
            [IronSource setISDemandOnlyRewardedVideoDelegate:self];
            [IronSource setISDemandOnlyInterstitialDelegate:self];
            [IronSource setBannerDelegate:self];
            [IronSource initISDemandOnly:config.appId adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_BANNER]];

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

- (void)updatePrivacy {
    [super updatePrivacy];
    [IronSource setConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
    [IronSource setMetaDataWithKey:@"do_not_sell" value:[Yodo1Mas sharedInstance].isCCPADoNotSell ? @"YES" : @"NO"];
}

#pragma mark - 激励广告

- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return [self getRewardAdId] != nil && [IronSource hasISDemandOnlyRewardedVideo:[self getRewardAdId].adId];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if ([self getRewardAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", TAG];
        NSLog(message);
        [IronSource loadISDemandOnlyRewardedVideo:[self getRewardAdId].adId];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd, show reward ad...}", TAG];
            NSLog(message);
            [IronSource showISDemandOnlyRewardedVideo:controller instanceId:[self getRewardAdId].adId];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate

- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidLoad:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)adError instanceId:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidFailToLoadWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, adError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    [self loadRewardAdDelayed];
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidOpen:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidClose:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)ironSourceError instanceId:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidFailToShowWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, ironSourceError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedVideoDidClick:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidClick:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoAdRewarded:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - 插屏广告

- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [self getInterstitialAdId] != nil && [IronSource hasISDemandOnlyInterstitial: [self getInterstitialAdId].adId];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if ( [self getInterstitialAdId] != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", TAG];
        NSLog(message);
        [IronSource loadISDemandOnlyInterstitial:[self getInterstitialAdId].adId];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:, show interstitial ad...}", TAG];
            NSLog(message);
            [IronSource showISDemandOnlyRewardedVideo:controller instanceId: [self getInterstitialAdId].adId];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - ISDemandOnlyInterstitialDelegate

- (void)interstitialDidLoad:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidLoad:, show instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

- (void)interstitialDidFailToLoadWithError:(NSError *)adError instanceId:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToLoadWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, adError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialDidOpen:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidOpen:, instanceId: %@}", TAG, instanceId];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidClose:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidClose:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidFailToShowWithError:(NSError *)ironSourceError instanceId:(NSString *)instanceId {

    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToShowWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, ironSourceError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAd];
}

- (void)didClickInterstitial:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickInterstitial:, instanceId: %@}", TAG, instanceId];
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
        [IronSource loadBannerWithViewController:[Yodo1MasIronSourceAdapter getTopViewController] size:ISBannerSize_BANNER placement:[self getBannerAdId].adId];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}", TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
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
