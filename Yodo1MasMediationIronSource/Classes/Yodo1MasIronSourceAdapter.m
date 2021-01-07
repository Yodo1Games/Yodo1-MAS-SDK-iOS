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
    return @"0.0.0.1-beta";
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
            [self loadRewardAdvert];
            [self loadInterstitialAdvert];
            [self loadBannerAdvert];

            if (successful != nil) {
                successful(self.advertCode);
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}", TAG];
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

- (void)updatePrivacy {
    [super updatePrivacy];
    [IronSource setConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
    [IronSource setMetaDataWithKey:@"do_not_sell" value:[Yodo1Mas sharedInstance].isCCPADoNotSell ? @"YES" : @"NO"];
}

#pragma mark - 激励广告

- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return self.rewardPlacementId != nil && [IronSource hasISDemandOnlyRewardedVideo:self.rewardPlacementId];
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    if (self.rewardPlacementId != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAdvert, loading reward ad...}", TAG];
        NSLog(message);
        [IronSource loadISDemandOnlyRewardedVideo:self.rewardPlacementId];
    }
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback object:(NSDictionary *)object {
    [super showRewardAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAdvert, show reward ad...}", TAG];
            NSLog(message);
            [IronSource showISDemandOnlyRewardedVideo:controller instanceId:self.rewardPlacementId];
        }
    }
}

- (void)dismissRewardAdvert {
    
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate

- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidLoad:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)adError instanceId:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidFailToLoadWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, adError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvertDelayed];
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidOpen:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidClose:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)ironSourceError instanceId:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidFailToShowWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, ironSourceError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    [self loadRewardAdvert];
}

- (void)rewardedVideoDidClick:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoDidClick:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoAdRewarded:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
}

#pragma mark - 插屏广告

- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return self.interstitialPlacementId != nil && [IronSource hasISDemandOnlyInterstitial:self.interstitialPlacementId];
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    if (self.interstitialPlacementId != nil) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert, loading interstitial ad...}", TAG];
        NSLog(message);
        [IronSource loadISDemandOnlyInterstitial:self.interstitialPlacementId];
    }
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:, show interstitial ad...}", TAG];
            NSLog(message);
            [IronSource showISDemandOnlyRewardedVideo:controller instanceId:self.rewardPlacementId];
        }
    }
}

- (void)dismissInterstitialAdvert {
    
}

#pragma mark - ISDemandOnlyInterstitialDelegate

- (void)interstitialDidLoad:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidLoad:, show instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

- (void)interstitialDidFailToLoadWithError:(NSError *)adError instanceId:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToLoadWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, adError];
    NSLog(message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvertDelayed];
}

- (void)interstitialDidOpen:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidOpen:, instanceId: %@}", TAG, instanceId];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidClose:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidClose:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidFailToShowWithError:(NSError *)ironSourceError instanceId:(NSString *)instanceId {

    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToShowWithError:instanceId:, instanceId: %@, error: %@}", TAG, instanceId, ironSourceError];
    NSLog(message);

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    [self loadInterstitialAdvert];
}

- (void)didClickInterstitial:(NSString *)instanceId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickInterstitial:, instanceId: %@}", TAG, instanceId];
    NSLog(message);
}

#pragma mark - 横幅广告

- (BOOL)isBannerAdvertLoaded {
    [super isBannerAdvertLoaded];
    return self.bannerPlacementId != nil && self.bannerAd != nil;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
    if (self.bannerPlacementId != nil && self.bannerPlacementId.length > 0) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:loadBannerAdvert:, loading banner ad...}", TAG];
        NSLog(message);
        [IronSource loadBannerWithViewController:[Yodo1MasIronSourceAdapter getTopViewController] size:ISBannerSize_BANNER placement:self.bannerPlacementId];
    }
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback object:(NSDictionary *)object {
    [super showBannerAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAdvert:align:, show banner ad...}", TAG];
        NSLog(message);
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd controller:controller object:object];
    }
}

- (void)dismissBannerAdvert {
    [super dismissBannerAdvert];
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

    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdvertTypeBanner];
    [self loadBannerAdvertDelayed];
}

- (void)didClickBanner {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickBanner}", TAG];
    NSLog(message);
}

- (void)bannerWillPresentScreen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillPresentScreen}", TAG];
    NSLog(message);
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeBanner];
}

- (void)bannerDidDismissScreen {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidDismissScreen}", TAG];
    NSLog(message);

    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeBanner];
    [self loadBannerAdvert];
}

- (void)bannerWillLeaveApplication {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillLeaveApplication}", TAG];
    NSLog(message);
}

@end
