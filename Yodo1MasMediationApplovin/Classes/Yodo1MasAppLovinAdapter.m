//
//  Yodo1MasAppLovinAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAppLovinAdapter.h"
@import  AppLovinSDK;

#define BANNER_TAG 10002

@interface Yodo1MasAppLovinAdapterRewardDelegete : NSObject<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate, ALAdRewardDelegate>

- (instancetype)initWithAdapter:(Yodo1MasAppLovinAdapter *)adapter;

@end

@implementation Yodo1MasAppLovinAdapterRewardDelegete {
    Yodo1MasAppLovinAdapter *_adapter;
}

- (instancetype)initWithAdapter:(Yodo1MasAppLovinAdapter *)adapter {
    self = [super init];
    if (self) {
        _adapter = adapter;
    }
    return self;
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    NSLog(@"%@: {method:adService:didLoadAd:,Reward, ad:%@}", _adapter.TAG, ad.adIdNumber);
    [_adapter callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adService:didFailToLoadAdWithError:,Reward, error: %@}", _adapter.TAG, @(code)];
    NSLog(@"%@", message);
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [_adapter callbackWithError:error type:Yodo1MasAdTypeReward];
    [_adapter loadAdDelayed:Yodo1MasAdTypeReward];
}

#pragma mark - ALAdDisplayDelegate
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    NSLog(@"%@: {method:ad:wasDisplayedIn:, Reward, ad:%@}", _adapter.TAG, ad.adIdNumber);
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    NSLog(@"%@: {method:didHideAd:, Reward, ad:%@}",_adapter.TAG, ad.adIdNumber);
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [_adapter loadAd:Yodo1MasAdTypeReward];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    NSLog(@"%@: {method:ad:wasClickedIn:,Reward, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

#pragma mark - ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad {
    NSLog(@"%@: {method:videoPlaybackBeganInAd:,Reward, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {
    NSLog(@"%@: {method:videoPlaybackEndedInAd:atPlaybackPercent:fullyWatched:,Reward, ad:%@}",_adapter.TAG, ad.adIdNumber);
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - ALAdRewardDelegate
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response {
    
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response {
    
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response {
    
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode {
    
}

@end


@interface Yodo1MasAppLovinAdapterInterstitialDelegete : NSObject<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

- (instancetype)initWithAdapter:(Yodo1MasAppLovinAdapter *)adapter;

@end

@implementation Yodo1MasAppLovinAdapterInterstitialDelegete {
    Yodo1MasAppLovinAdapter *_adapter;
}

- (instancetype)initWithAdapter:(Yodo1MasAppLovinAdapter *)adapter {
    self = [super init];
    if (self) {
        _adapter = adapter;
    }
    return self;
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    NSLog(@"%@: {method:adService:didLoadAd:, Interstitial, ad:%@}", _adapter.TAG, ad.adIdNumber);
    _adapter.interstitialState = Yodo1MasBannerStateLoaded;
    [_adapter callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adService:didFailToLoadAdWithError:,Interstitial, error: %@}", _adapter.TAG, @(code)];
    NSLog(@"%@", message);
    
    _adapter.interstitialState = Yodo1MasBannerStateNone;
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [_adapter callbackWithError:error type:Yodo1MasAdTypeInterstitial];
    [_adapter loadAdDelayed:Yodo1MasAdTypeInterstitial];
}

#pragma mark - ALAdDisplayDelegate
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    NSLog(@"%@: {method:ad:wasDisplayedIn:,Interstitial, ad:%@}", _adapter.TAG, ad.adIdNumber);
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    NSLog(@"%@: {method:didHideAd:,Interstitial, ad:%@}",_adapter.TAG, ad.adIdNumber);

    _adapter.interstitialState = Yodo1MasBannerStateNone;
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [_adapter loadAd:Yodo1MasAdTypeInterstitial];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    NSLog(@"%@: {method:didHideAd:,Interstitial, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

#pragma mark - ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad {
    NSLog(@"%@: {method:videoPlaybackBeganInAd:,Interstitial, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched {
    NSLog(@"%@: {method:videoPlaybackEndedInAd:atPlaybackPercent:fullyWatched:,Interstitial, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

@end


@interface Yodo1MasAppLovinAdapterBannerDelegete : NSObject<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate>

- (instancetype)initWithAdapter:(Yodo1MasAppLovinAdapter *)adapter;

@end

@implementation Yodo1MasAppLovinAdapterBannerDelegete {
    Yodo1MasAppLovinAdapter *_adapter;
}

- (instancetype)initWithAdapter:(Yodo1MasAppLovinAdapter *)adapter {
    self = [super init];
    if (self) {
        _adapter = adapter;
    }
    return self;
}

#pragma mark - ALAdLoadDelegate
- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    NSLog(@"%@: {method:adService:didLoadAd:, Banner, ad:%@}", _adapter.TAG, ad.adIdNumber);
    _adapter.bannerState = Yodo1MasBannerStateLoaded;
    [_adapter callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSString *message = [NSString stringWithFormat:@"%@: {method:adService:didFailToLoadAdWithError:,Banner, error: %@}", _adapter.TAG, @(code)];
    NSLog(@"%@", message);
    
    _adapter.bannerState = Yodo1MasBannerStateNone;
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [_adapter callbackWithError:error type:Yodo1MasAdTypeBanner];
    [_adapter loadAdDelayed:Yodo1MasAdTypeBanner];
}

#pragma mark - ALAdDisplayDelegate
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    NSLog(@"%@: {method:ad:wasDisplayedIn:,Banner, ad:%@}", _adapter.TAG, ad.adIdNumber);
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    NSLog(@"%@: {method:didHideAd:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);

    _adapter.bannerState = Yodo1MasBannerStateNone;
    [_adapter callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [_adapter loadAd:Yodo1MasAdTypeInterstitial];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    NSLog(@"%@: {method:didHideAd:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

#pragma mark - ALAdViewEventDelegate
- (void)ad:(ALAd *)ad didPresentFullscreenForAdView:(ALAdView *)adView {
    NSLog(@"%@: {method:ad:didPresentFullscreenForAdView:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)ad:(ALAd *)ad willDismissFullscreenForAdView:(ALAdView *)adView {
    NSLog(@"%@: {method:ad:willDismissFullscreenForAdView:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)ad:(ALAd *)ad didDismissFullscreenForAdView:(ALAdView *)adView {
    NSLog(@"%@: {method:ad:didDismissFullscreenForAdView:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)ad:(ALAd *)ad willLeaveApplicationForAdView:(ALAdView *)adView {
    NSLog(@"%@: {method:ad:willLeaveApplicationForAdView:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)ad:(ALAd *)ad didReturnToApplicationForAdView:(ALAdView *)adView {
    NSLog(@"%@: {method:ad:didReturnToApplicationForAdView:,Banner, ad:%@}",_adapter.TAG, ad.adIdNumber);
}

- (void)ad:(ALAd *)ad didFailToDisplayInAdView:(ALAdView *)adView withError:(ALAdViewDisplayErrorCode)code {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method:ad:didFailToDisplayInAdView:withError:, ad:%@, error:%@}", _adapter.TAG, ad.adIdNumber, @(code)];
    NSLog(@"%@", message);
    
    _adapter.bannerState = Yodo1MasBannerStateNone;
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [_adapter callbackWithError:error type:Yodo1MasAdTypeBanner];
    [_adapter loadAd:Yodo1MasAdTypeBanner];
}

@end

@interface Yodo1MasAppLovinAdapter()

@property (nonatomic, strong) ALSdk *sdk;

@property (nonatomic, strong) ALIncentivizedInterstitialAd *rewardAd;
@property (nonatomic, strong) Yodo1MasAppLovinAdapterRewardDelegete *rewardDelegate;

@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, strong) Yodo1MasAppLovinAdapterInterstitialDelegete *interstitialDelegete;

@property (nonatomic, strong) ALAdView *bannerAd;
@property (nonatomic, strong) Yodo1MasAppLovinAdapterBannerDelegete *bannerDelegate;

@end

@implementation Yodo1MasAppLovinAdapter

- (NSString *)advertCode {
    return @"applovin";
}

- (NSString *)sdkVersion {
    return [ALSdk version];
}

- (NSString *)mediationVersion {
    return @"4.1.0-NoAdMob";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    if (![self isInitSDK]) {
        self.sdk = [ALSdk shared];
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
    if (_rewardDelegate == nil) {
        _rewardDelegate = [[Yodo1MasAppLovinAdapterRewardDelegete alloc] initWithAdapter:self];
    }
    if (_interstitialDelegete == nil) {
        _interstitialDelegete = [[Yodo1MasAppLovinAdapterInterstitialDelegete alloc] initWithAdapter:self];
    }
    if (_bannerDelegate == nil) {
        _bannerDelegate = [[Yodo1MasAppLovinAdapterBannerDelegete alloc] initWithAdapter:self];
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
    return self.rewardAd != nil && self.rewardAd.isReadyForDisplay;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if (self.rewardAd == nil) {
        self.rewardAd = [ALIncentivizedInterstitialAd shared];
        self.rewardAd.adDisplayDelegate = _rewardDelegate;
        self.rewardAd.adVideoPlaybackDelegate = _rewardDelegate;
    }
    
    if (self.rewardAd != nil) {
        NSLog(@"%@: {method:loadRewardAd, loading reward ad...}", self.TAG);
        [self.rewardAd preloadAndNotify:_rewardDelegate];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        NSLog(@"%@: {method:showRewardAd, show reward ad...}", self.TAG);
        [self.rewardAd showAndNotify:_rewardDelegate];
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return self.interstitialAd != nil && self.interstitialState == Yodo1MasBannerStateLoaded;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if (self.interstitialAd == nil) {
        self.interstitialAd = [ALInterstitialAd shared];
        self.interstitialAd.adLoadDelegate = _interstitialDelegete;
        self.interstitialAd.adDisplayDelegate = _interstitialDelegete;
        self.interstitialAd.adVideoPlaybackDelegate = _interstitialDelegete;
    }
    
    if (self.interstitialAd != nil) {
        NSLog(@"%@: {method:loadInterstitialAd, loading interstitial ad...}", self.TAG);
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        NSLog(@"%@: {method:loadInterstitialAd, show interstitial ad...}", self.TAG);
        
        [self.interstitialAd show];
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerAd != nil && self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    if (self.bannerAd == nil) {
        self.bannerAd = [[ALAdView alloc] initWithSize: ALAdSize.banner];;
        self.bannerAd.frame = CGRectMake(0, 0, BANNER_SIZE_320_50.width, BANNER_SIZE_320_50.height);
        self.bannerAd.adLoadDelegate = _bannerDelegate;
        self.bannerAd.adDisplayDelegate = _bannerDelegate;
        self.bannerAd.adEventDelegate = _bannerDelegate;
    }
    if (self.bannerAd != nil && self.bannerState != Yodo1MasBannerStateLoading) {
        NSLog(@"%@: {method:loadBannerAd, loading banner ad...}", self.TAG);
        [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:[Yodo1MasAppLovinAdapter getTopViewController]];
        [self.bannerAd loadNextAd];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSLog(@"%@: {method:showBannerAd:, show banner ad...}", self.TAG);
        UIViewController *controller = [Yodo1MasAppLovinAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.bannerAd tag:BANNER_TAG controller:controller object:object];
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

@end
