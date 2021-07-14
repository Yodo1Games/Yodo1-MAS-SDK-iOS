//
//  Yodo1MasTencentAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasTencentAdapter.h"
#import "GDTSDKConfig.h"
#import "GDTUnifiedBannerView.h"
#import "GDTUnifiedInterstitialAd.h"
#import "GDTSplashAd.h"
#import "GDTRewardVideoAd.h"

#define BANNER_TAG 10015

@interface Yodo1MasTencentAdapter()
<GDTUnifiedBannerViewDelegate,
GDTUnifiedInterstitialAdDelegate,
GDTRewardedVideoAdDelegate>

@property(nonatomic,assign) BOOL sdkInit;
@property(nonatomic,strong) GDTUnifiedBannerView     * adBanner;
@property(nonatomic,strong) GDTUnifiedInterstitialAd * interstitialAd;
@property(nonatomic,strong) GDTRewardVideoAd         * rewardVideoAd;

@end

@implementation Yodo1MasTencentAdapter

- (NSString *)advertCode {
    return @"tencent";
}

- (NSString *)sdkVersion {
    return [GDTSDKConfig sdkVersion];
}

-(GDTUnifiedBannerView *)adBanner {
    if (!_adBanner && [self getBannerAdId]) {
        CGRect rect = CGRectMake(0, 0, [self adSize].width, [self adSize].height);
        _adBanner = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:[self getBannerAdId].adId ? : @"" viewController:[Yodo1MasTencentAdapter getTopViewController]];
        _adBanner.animated = YES;
        _adBanner.delegate = self;
        _adBanner.autoSwitchInterval = 15;
    }
    return _adBanner;
}

-(GDTUnifiedInterstitialAd *)interstitialAd {
    if (!_interstitialAd && [self getInterstitialAdId]) {
        _interstitialAd = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:[self getInterstitialAdId].adId];
        _interstitialAd.delegate = self;
    }
    return _interstitialAd;
}

-(GDTRewardVideoAd *)rewardVideoAd {
    if (!_rewardVideoAd && [self getRewardAdId]) {
        _rewardVideoAd = [[GDTRewardVideoAd alloc] initWithPlacementId:[self getRewardAdId].adId];
        _rewardVideoAd.delegate = self;
    }
    return _rewardVideoAd;
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        if (config.appId != nil && config.appId.length > 0) {
            [GDTSDKConfig registerAppId:config.appId];
            [GDTSDKConfig enableDefaultAudioSessionSetting:NO];
            [GDTSDKConfig setChannel:14];
            self.sdkInit = YES;
            [self updatePrivacy];
            [self loadRewardAd];
            [self loadInterstitialAd];
            [self loadBannerAd];
            if (self.initSuccessfulCallback != nil) {
                self.initSuccessfulCallback(self.advertCode);
            }
            if (successful != nil) {
                successful(self.advertCode);
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
    return self.rewardVideoAd.isAdValid;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    if (self.isRewardAdLoaded) {return;}
    [self.rewardVideoAd loadAd];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasTencentAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [self.rewardVideoAd showAdFromRootViewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark- GDTRewardVideoAdDelegate

- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: gdt_rewardVideoAd:didFailWithError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *rewardError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:rewardError type:Yodo1MasAdTypeReward];
    self.rewardVideoAd = nil;
    [self nextReward];
    [self loadRewardAdDelayed];
}

- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd info:(nonnull NSDictionary *)info {
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return self.interstitialAd.isAdValid;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    if ([self isInterstitialAdLoaded]) {return;}
    [self.interstitialAd loadAd];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasTencentAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd presentAdFromRootViewController:controller];
        }
        
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma  mark- GDTUnifiedInterstitialAdDelegate

- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedInterstitialFailToLoadAd:error:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeInterstitial];
    self.interstitialAd = nil;
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedInterstitialFailToPresent:error:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *tencentError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:tencentError type:Yodo1MasAdTypeInterstitial];
    [self nextInterstitial];
    [self loadInterstitialAd];
}

- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    self.interstitialAd = nil;
    [self loadInterstitialAd];
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
    if (self.adBanner.superview) {
        [self.adBanner removeFromSuperview];
        self.adBanner.delegate = nil;
        self.adBanner = nil;
    }
    [self.adBanner loadAdAndShow];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        
        UIViewController *controller = [Yodo1MasTencentAdapter getTopViewController];
        if (controller != nil) {
            [Yodo1MasBanner addBanner:self.adBanner tag:BANNER_TAG controller:controller];
        }
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

#pragma mark GDTUnifiedBannerViewDelegate

- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    self.bannerState = Yodo1MasBannerStateLoaded;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
    [self callbackWithEvent:Yodo1MasAdEventCodeLoaded type:Yodo1MasAdTypeBanner];
}

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedBannerViewFailedToLoad:error, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *pangleError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:pangleError type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedBannerViewWillExpose}", self.TAG];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView {
    NSString *message = [NSString stringWithFormat:@"%@: {method: unifiedBannerViewWillClose}", self.TAG];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    self.adBanner = nil;
    self.bannerState = Yodo1MasBannerStateNone;
    [self loadBannerAd];
}

@end
