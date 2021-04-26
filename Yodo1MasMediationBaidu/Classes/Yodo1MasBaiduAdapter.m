//
//  Yodo1MasBaiduAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasBaiduAdapter.h"
#import "BaiduMobAdSDK/BaiduMobAdView.h"
#import "BaiduMobAdSDK/BaiduMobAdSetting.h"
#import "BaiduMobAdSDK/BaiduMobAdDelegateProtocol.h"
#import "BaiduMobAdSDK/BaiduMobAdInterstitial.h"
#import "BaiduMobAdSDK/BaiduMobAdRewardVideo.h"

#define BANNER_TAG 10017

@interface Yodo1MasBaiduAdapter()
<BaiduMobAdViewDelegate,
BaiduMobAdInterstitialDelegate,
BaiduMobAdRewardVideoDelegate>

@property(nonatomic,assign) BOOL sdkInit;
@property(nonatomic,strong) BaiduMobAdView         * adBanner;
@property(nonatomic,strong) BaiduMobAdInterstitial * interstitialAd;
@property(nonatomic,strong) BaiduMobAdRewardVideo  * rewardVideoAd;

@property(nonatomic,copy) NSString* publisherId;

@end

@implementation Yodo1MasBaiduAdapter

- (NSString *)advertCode {
    return @"baidu";
}

- (NSString *)sdkVersion {
    return SDK_VERSION_IN_MSSP;
}

- (NSString *)mediationVersion {
    return @"4.1.0-NoAdMob";
}

-(BaiduMobAdView *)adBanner {
    if (!_adBanner) {
        CGRect rect = CGRectMake(0, 0, [self adSize].width, [self adSize].height);
        _adBanner = [[BaiduMobAdView alloc] init];
        _adBanner.delegate = self;
        _adBanner.AdType = BaiduMobAdViewTypeBanner;
        _adBanner.AdUnitTag = [self getBannerAdId].adId;
        [_adBanner setFrame:rect];
        [self.adBanner start];
    }
    return _adBanner;
}

-(BaiduMobAdInterstitial *)interstitialAd {
    if (!_interstitialAd) {
        _interstitialAd = [[BaiduMobAdInterstitial alloc] init];
        _interstitialAd.delegate = self;
        _interstitialAd.AdUnitTag = [self getInterstitialAdId].adId;
        _interstitialAd.interstitialType = BaiduMobAdViewTypeInterstitialOther;
    }
    
    return _interstitialAd;
}

-(BaiduMobAdRewardVideo *)rewardVideoAd {
    if (!_rewardVideoAd) {
        _rewardVideoAd = [[BaiduMobAdRewardVideo alloc]init];
        _rewardVideoAd.delegate = self;
        _rewardVideoAd.publisherId = _publisherId;
        _rewardVideoAd.AdUnitTag = [self getRewardAdId].adId;
    }
    
    return _rewardVideoAd;
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        if (config.appId != nil && config.appId.length > 0) {
            [BaiduMobAdSetting sharedInstance].supportHttps = YES;
            
            _publisherId = config.appId;
            self.sdkInit = YES;

            [self updatePrivacy];
            [self loadRewardAd];
            [self loadInterstitialAd];
            [self loadBannerAd];
            if (self.initSuccessfulCallback != nil) {
                self.initSuccessfulCallback(self.advertCode);
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",self.TAG];
            NSLog(@"%@", message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
                fail(self.advertCode, error);
            }
        }
    }
    if (successful != nil) {
        successful(self.advertCode);
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return self.sdkInit;
}

- (void)updatePrivacy {
    [super updatePrivacy];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return [self.rewardVideoAd isReady];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if (self.isRewardAdLoaded) {return;}
    [self.rewardVideoAd load];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasBaiduAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [self.rewardVideoAd showFromViewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark- BaiduMobAdRewardVideoDelegate

- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoAdLoadFailed, reason: %u}", self.TAG, reason];
    NSLog(@"%@", message);
    Yodo1MasError *rewardError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:rewardError type:Yodo1MasAdTypeReward];
    self.rewardVideoAd = nil;
    [self nextReward];
    [self loadRewardAdDelayed];
}

- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedVideoAdShowFailed, error: %u}", self.TAG, reason];
    NSLog(@"%@", message);
    Yodo1MasError *baiduError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:baiduError type:Yodo1MasAdTypeReward];
    self.rewardVideoAd = nil;
    [self nextReward];
    [self loadRewardAdDelayed];
}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [self.interstitialAd isReady];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if ([self isInterstitialAdLoaded]) {return;}
    [self.interstitialAd load];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasBaiduAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd presentFromRootViewController:controller];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - BaiduMobAdInterstitialDelegate

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedInterstitialFailToLoadAd:error:, adUnitTag: %@}", self.TAG, interstitial.AdUnitTag];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeInterstitial];
    self.interstitialAd = nil;
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {

}

- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedInterstitialFailToPresent:error:, error: %u}", self.TAG, reason];
    NSLog(@"%@", message);
    Yodo1MasError *baiduError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:baiduError type:Yodo1MasAdTypeInterstitial];
    self.interstitialAd = nil;
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
   
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial{
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    self.interstitialAd = nil;
    [self loadInterstitialAd];
}

- (void)interstitialDidDismissLandingPage:(BaiduMobAdInterstitial *)interstitial {

}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return self.bannerState == Yodo1MasBannerStateLoaded;
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    if ([self isBannerAdLoaded]) {return;}
    self.bannerState = Yodo1MasBannerStateLoading;
    UIViewController *controller = [Yodo1MasBaiduAdapter getTopViewController];
    if (controller != nil) {
        [Yodo1MasBanner addBanner:self.adBanner tag:BANNER_TAG controller:controller];
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        UIViewController *controller = [Yodo1MasBaiduAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.adBanner tag:BANNER_TAG controller:controller object:object];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.adBanner tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        self.adBanner = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}

#pragma mark BaiduMobAdViewDelegate

- (void)willDisplayAd:(BaiduMobAdView *)adview {
    NSString *message = [NSString stringWithFormat:@"%@: {method:willDisplayAd:, banner: %@}",self.TAG, adview.AdUnitTag];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateLoaded;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {
    NSString *message = [NSString stringWithFormat:@"%@: {method: failedDisplayAd:error, reason: %u}", self.TAG, reason];
    NSLog(@"%@", message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:error type:Yodo1MasAdTypeBanner];
    self.bannerState = Yodo1MasBannerStateNone;
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)didAdImpressed {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didAdImpressed:, banner}",self.TAG];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)didAdClicked {
    NSString *message = [NSString stringWithFormat:@"%@: {method:didAdClicked:, banner}",self.TAG];
    NSLog(@"%@", message);
}

- (void)didAdClose {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didAdClose}", self.TAG];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    self.adBanner = nil;
    self.bannerState = Yodo1MasBannerStateNone;
    [self loadBannerAd];
}

@end
