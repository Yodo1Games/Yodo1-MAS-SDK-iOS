//
//  Yodo1MasPangleAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasPangleAdapter.h"
#import <BUAdSDK/BUAdSDK.h>

#define BANNER_TAG 10014

@interface Yodo1MasPangleAdapter()<
BURewardedVideoAdDelegate,
BUFullscreenVideoAdDelegate,
BUNativeExpressBannerViewDelegate
> {
    BOOL isBanerAdReady;
    BOOL isRewardAdReady;
    BOOL isInterstitialAdReady;
}


@property (nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) BUNativeExpressBannerView *bannerAd;
@property (nonatomic, strong) BUFullscreenVideoAd *interstitialAd;
@property (nonatomic, strong) BURewardedVideoAd *rewardAd;
@property (nonatomic, strong) BURewardedVideoModel *rewardModel;

@end

@implementation Yodo1MasPangleAdapter

- (NSString *)advertCode {
    return @"pangle";
}

- (NSString *)sdkVersion {
    return BUAdSDKManager.SDKVersion;
}

- (NSString *)mediationVersion {
    return @"4.2.0";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [self updatePrivacy];
        [BUAdSDKManager setAppID:config.appId];
        [BUAdSDKManager setIsPaidApp:NO];
        self.sdkInit = YES;
        [self loadRewardAd];
        [self loadInterstitialAd];
        [self loadBannerAd];
        if (successful != nil) {
            successful(self.advertCode);
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
    [BUAdSDKManager setGDPR:Yodo1Mas.sharedInstance.isGDPRUserConsent];
    [BUAdSDKManager setCoppa:Yodo1Mas.sharedInstance.isCOPPAAgeRestricted];
}


#pragma mark - 激励广告

- (BURewardedVideoAd *)rewardAd {
    if (!_rewardAd) {
        _rewardModel = [[BURewardedVideoModel alloc] init];
        _rewardModel.userId = @"";
        Yodo1MasAdId *adId = [self getRewardAdId];
        _rewardAd = [[BURewardedVideoAd alloc] initWithSlotID:adId.adId
                                           rewardedVideoModel:_rewardModel];
        _rewardAd.delegate = self;
    }
    return _rewardAd;
}

- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return isRewardAdReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    [self.rewardAd loadAdData];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [self.rewardAd showAdFromRootViewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告

- (BUFullscreenVideoAd *)interstitialAd {
    if (!_interstitialAd) {
        Yodo1MasAdId *adId = [self getInterstitialAdId];
        _interstitialAd = [[BUFullscreenVideoAd alloc] initWithSlotID:adId.adId];
        _interstitialAd.delegate = self;
    }
    return _interstitialAd;
}

- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return isInterstitialAdReady;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    [self.interstitialAd loadAdData];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd showAdFromRootViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告

- (BUNativeExpressBannerView *)bannerAd {
    if (!_bannerAd) {
        Yodo1MasAdId *adId = [self getBannerAdId];
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        _bannerAd = [[BUNativeExpressBannerView alloc] initWithSlotID:adId.adId rootViewController:controller adSize:self.adSize interval:15];
        _bannerAd.delegate = self;
    }
    return _bannerAd;
}

- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return isBanerAdReady;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    [self.bannerAd loadAdData];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        if (controller != nil) {
            [Yodo1MasBanner addBanner:self.bannerAd tag:BANNER_TAG controller:controller];
        }
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


#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    isRewardAdReady = YES;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    isRewardAdReady = NO;
    NSString *message = [NSString stringWithFormat:@"%@: {method: didFailWithError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *rewardError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:rewardError type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    self.rewardAd = nil;
    self.rewardModel = nil;
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    if (verify) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

#pragma mark - BUFullscreenVideoAdDelegate

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    isInterstitialAdReady = YES;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    self.interstitialAd = nil;
    isInterstitialAdReady = YES;
    [self nextInterstitial];
    [self loadInterstitialAd];
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    isInterstitialAdReady = NO;
    NSString *message = [NSString stringWithFormat:@"%@: {method: fullscreenVideoAd:didFailWithError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeInterstitial];
    [self nextInterstitial];
    [self loadInterstitialAd];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: fullscreenVideoAd:didFailWithError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeInterstitial];
}

#pragma BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    self.bannerAd = bannerAdView;
    self.bannerAd.frame = CGRectMake(0,0,self.adSize.width,self.adSize.height);
    isBanerAdReady = YES;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    isBanerAdReady = NO;
    NSString *message = [NSString stringWithFormat:@"%@: {method: nativeExpressBannerAdView:didLoadFailWithError, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: nativeExpressBannerAdViewRenderFail:error, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeBanner];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: nativeExpressBannerAdViewWillBecomVisible}", self.TAG];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    
    [UIView animateWithDuration:0.25 animations:^{
        bannerAdView.alpha = 0;
    } completion:^(BOOL finished) {
        [bannerAdView removeFromSuperview];
        self.bannerAd = nil;
    }];
    isBanerAdReady = NO;
}


@end
