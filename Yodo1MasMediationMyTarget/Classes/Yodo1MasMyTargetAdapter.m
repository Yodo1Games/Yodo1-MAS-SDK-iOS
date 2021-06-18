//
//  Yodo1MasMyTargetAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasMyTargetAdapter.h"
#import <MyTargetSDK/MyTargetSDK.h>

#define BANNER_TAG 10010


@interface Yodo1MasMyTargetAdapter()<MTRGInterstitialAdDelegate,MTRGAdViewDelegate> {
    BOOL isRewardAdReady;
    BOOL isInterstitialAdReady;
}

@property(nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) MTRGAdView *bannerAd;
@property (nonatomic, strong) MTRGInterstitialAd *interstitialAd;
@property (nonatomic, strong) MTRGInterstitialAd *rewardAd;

@end

@implementation Yodo1MasMyTargetAdapter

- (NSString *)advertCode {
    return @"mytarget";
}

- (NSString *)sdkVersion {
    return MTRGVersion.currentVersion;
}

- (NSString *)mediationVersion {
    return @"4.2.0-beta";
}

-(void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail  {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        self.sdkInit = YES;
        [self updatePrivacy];
        [self loadBannerAd];
        [self loadInterstitialAd];
        [self loadRewardAd];
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
    [MTRGPrivacy setUserConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
    [MTRGPrivacy setUserAgeRestricted:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    [MTRGPrivacy setCcpaUserConsent:[Yodo1Mas sharedInstance].isCCPADoNotSell];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return isRewardAdReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG];
    NSLog(@"%@", message);
    [self.rewardAd load];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasMyTargetAdapter getTopViewController];
        if (controller != nil) {
            [self.rewardAd showWithController:controller];
        }
    }
}

- (MTRGInterstitialAd *)rewardAd {
    if (!_rewardAd) {
        Yodo1MasAdId *adId = [self getRewardAdId];
        if (adId != nil && adId.adId != nil) {
            NSInteger slotId = [adId.adId intValue];
            _rewardAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
            _rewardAd.delegate = self;
        }
    }
    return  _rewardAd;
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return isInterstitialAdReady;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", self.TAG];
    NSLog(@"%@", message);
    [self.interstitialAd load];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasMyTargetAdapter getTopViewController];
        if (controller != nil) {
            [self.interstitialAd showWithController:controller];
        }
    }
}

- (MTRGInterstitialAd *)interstitialAd {
    if (!_interstitialAd) {
        Yodo1MasAdId *adId = [self getInterstitialAdId];
        if (adId != nil && adId.adId != nil) {
            NSInteger slotId = [adId.adId intValue];
            _interstitialAd = [[MTRGInterstitialAd alloc] initWithSlotId:slotId];
            _interstitialAd.delegate = self;
        }
    }
    return  _interstitialAd;
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return [self getBannerAdId] != nil && self.bannerAd != nil;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    UIViewController *controller = [Yodo1MasMyTargetAdapter getTopViewController];
    [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:controller];
    [self.bannerAd load];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:align:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        UIViewController *controller = [Yodo1MasMyTargetAdapter getTopViewController];
        [Yodo1MasBanner showBannerWithTag:BANNER_TAG controller:controller object:object];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}

- (MTRGAdView *)bannerAd {
    if (!_bannerAd) {
        MTRGAdSize *_adSize = MTRGAdSize.adSize320x50;
        Yodo1MasAdId *adId = [self getBannerAdId];
        NSInteger slotId = [adId.adId intValue];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _adSize = MTRGAdSize.adSize728x90;
        }
        _bannerAd = [MTRGAdView adViewWithSlotId:slotId shouldRefreshAd:YES];
        _bannerAd.adSize = _adSize;
        _bannerAd.delegate = self;
        _bannerAd.viewController = [Yodo1MasMyTargetAdapter getTopViewController];
    }
    return _bannerAd;
}

#pragma mark - MTRGInterstitialAdDelegate

- (void)onLoadWithInterstitialAd:(nonnull MTRGInterstitialAd *)interstitialAd {
    if (self.rewardAd == interstitialAd) {
        isRewardAdReady = YES;
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
    }else if (self.interstitialAd == interstitialAd){
        isInterstitialAdReady = YES;
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
    }
    NSString *message = [NSString stringWithFormat:@"%@: {method: onLoadWithInterstitialAd:, instanceId: %@}", self.TAG, interstitialAd];
    NSLog(@"%@", message);
}

- (void)onNoAdWithReason:(nonnull NSString *)reason interstitialAd:(nonnull MTRGInterstitialAd *)interstitialAd {
    if (self.rewardAd == interstitialAd) {
        isRewardAdReady = NO;
        NSString *message = [NSString stringWithFormat:@"%@: {method: onNoAdWithReason:instanceId:, instanceId: %@, error: %@}", self.TAG, interstitialAd, reason];
        NSLog(@"%@", message);
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAd];
    }else if (self.interstitialAd == interstitialAd){
        isInterstitialAdReady = NO;
        NSString *message = [NSString stringWithFormat:@"%@: {method: onNoAdWithReason:instanceId:, instanceId: %@, error: %@}", self.TAG, interstitialAd, reason];
        NSLog(@"%@", message);
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAd];
    }
}

- (void)onClickWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    
}

- (void)onCloseWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onCloseWithInterstitialAd:, instanceId: %@}", self.TAG, interstitialAd];
    NSLog(@"%@", message);
    if (self.rewardAd == interstitialAd) {
        self.rewardAd = nil;
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAd];
    }else if (self.interstitialAd == interstitialAd){
        self.interstitialAd = nil;
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAd];
    }
}

- (void)onVideoCompleteWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    if (self.rewardAd == interstitialAd) {
        NSString *message = [NSString stringWithFormat:@"%@: {method: onVideoCompleteWithInterstitialAd:, instanceId: %@}", self.TAG, interstitialAd];
        NSLog(@"%@", message);
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

- (void)onDisplayWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onDisplayWithInterstitialAd:, instanceId: %@}", self.TAG, interstitialAd];
    NSLog(@"%@", message);
    if (self.rewardAd == interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    }else if (self.interstitialAd == interstitialAd){
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)onLeaveApplicationWithInterstitialAd:(MTRGInterstitialAd *)interstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onLeaveApplicationWithInterstitialAd:, instanceId: %@}", self.TAG, interstitialAd];
    NSLog(@"%@", message);
    if (self.rewardAd == interstitialAd) {
        
    }else if (self.interstitialAd == interstitialAd){
        
    }
}

#pragma mark - MTRGAdViewDelegate

- (void)onLoadWithAdView:(nonnull MTRGAdView *)adView {
    self.bannerAd = adView;
    NSString *message = [NSString stringWithFormat:@"%@: {method: onLoadWithAdView:, banner: %@}", self.TAG, adView];
    NSLog(@"%@", message);
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
    [self callbackWithEvent:Yodo1MasAdEventCodeLoaded type:Yodo1MasAdTypeBanner];
}

- (void)onNoAdWithReason:(nonnull NSString *)reason adView:(nonnull MTRGAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onNoAdWithReason:, error: %@}", self.TAG, reason];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)onAdClickWithAdView:(MTRGAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClickBanner}", self.TAG];
    NSLog(@"%@", message);
}

- (void)onAdShowWithAdView:(MTRGAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onAdShowWithAdView}", self.TAG];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)onShowModalWithAdView:(MTRGAdView *)adView {
    
}

- (void)onDismissModalWithAdView:(MTRGAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidDismissScreen}", self.TAG];
    NSLog(@"%@", message);
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

- (void)onLeaveApplicationWithAdView:(MTRGAdView *)adView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerWillLeaveApplication}", self.TAG];
    NSLog(@"%@", message);
}

@end
