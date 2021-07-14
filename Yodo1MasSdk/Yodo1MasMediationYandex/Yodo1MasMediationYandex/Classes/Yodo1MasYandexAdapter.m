//
//  Yodo1MasYandexAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasYandexAdapter.h"
@import YandexMobileAds;

#define BANNER_TAG 10009

@interface Yodo1MasYandexAdapter()
<YMAAdViewDelegate,YMAInterstitialDelegate,YMARewardedAdDelegate>

@property(nonatomic,strong) YMAAdView           * adBanner;
//@property(nonatomic,strong) YMAInterstitialAd   * interstitialAd;//YandexMobileAds Version 3.x API
@property(nonatomic,strong) YMAInterstitialController * interstitialAd;//YandexMobileAds Version 2.x API
@property(nonatomic,strong) YMARewardedAd             * rewardVideoAd;
@property(nonatomic,assign) BOOL isYMSDKInit;

@end

@implementation Yodo1MasYandexAdapter

- (YMAAdView *)adBanner {
    if (!_adBanner && [self getBannerAdId]) {
        CGSize size = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YMAAdSizeBanner_320x50 : YMAAdSizeBanner_728x90;
        YMAAdSize * adSize = [YMAAdSize flexibleSizeWithCGSize:size];
//API Version 3.x
//        _adBanner = [[YMAAdView alloc] initWithBlockID:[self getBannerAdId].adId adSize:adSize];
//API Version 2.x
        _adBanner = [[YMAAdView alloc] initWithBlockID:[self getBannerAdId].adId adSize:adSize delegate:self];
        _adBanner.delegate = self;
    }
    return _adBanner;
}

//API Version 3.x
//
//-(YMAInterstitialAd *)interstitialAd {
//    if (!_interstitialAd && [self getInterstitialAdId].adId) {
//        _interstitialAd = [[YMAInterstitialAd alloc] initWithBlockID:[self getInterstitialAdId].adId];
//        _interstitialAd.delegate = self;
//    }
//    return _interstitialAd;
//}
//

//API Version 2.x
-(YMAInterstitialController *)interstitialAd {
    if (!_interstitialAd && [self getInterstitialAdId].adId) {
        _interstitialAd = [[YMAInterstitialController alloc] initWithBlockID:[self getInterstitialAdId].adId];
        _interstitialAd.delegate = self;
    }
    return _interstitialAd;
}

-(YMARewardedAd *)rewardVideoAd {
    if (!_rewardVideoAd && [self getRewardAdId].adId) {
        _rewardVideoAd = [[YMARewardedAd alloc] initWithBlockID:[self getRewardAdId].adId];
        _rewardVideoAd.delegate = self;
    }
    return _rewardVideoAd;
}

- (NSString *)advertCode {
    return @"yandex";
}

- (NSString *)sdkVersion {
    return [YMAMobileAds SDKVersion];
}

- (NSString *)mediationVersion {
    return @"4.3.0";
}

-(void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail  {
    [super initWithConfig:config successful:successful fail:fail];

    if (![self isInitSDK]) {
        self.isYMSDKInit = YES;
        [self updatePrivacy];
        [self loadBannerAd];
        [self loadInterstitialAd];
        [self loadRewardAd];
        if (!successful) {
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
    return self.isYMSDKInit;
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [YMAMobileAds setUserConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    if (![self isInitSDK]) {return NO;}
    return self.rewardVideoAd.loaded;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG];
    NSLog(@"%@", message);
    [self.rewardVideoAd load];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd, show reward ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.rewardVideoAd presentFromViewController:controller];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    if ([self isInitSDK]) {
        return self.interstitialAd.loaded && !self.interstitialAd.hasBeenPresented;
    }
    return NO;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    [self.interstitialAd load];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
//API Version 3.x
//            [self.interstitialAd presentFromViewController:controller];
//API Version 2.x
            [self.interstitialAd presentInterstitialFromViewController:controller];
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    if ([self isInitSDK]) {
        return self.adBanner != nil && self.bannerState == Yodo1MasBannerStateLoaded;
    }
    return NO;
}

- (void)loadBannerAd {
    if (![self isBannerAdLoaded]) {
        [super loadBannerAd];
        [self.adBanner loadAd];
        self.bannerState = Yodo1MasBannerStateLoading;
    }
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
        [Yodo1MasBanner showBanner:self.adBanner tag:BANNER_TAG controller:controller object:object];
    }
}

#pragma mark YMAAdViewDelegate

- (void)adViewDidLoad:(YMAAdView *)adView {
    NSLog(@"%@: {method: %s",self.TAG,__func__);
    self.bannerState = Yodo1MasBannerStateLoaded;
    UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
    [Yodo1MasBanner addBanner:self.adBanner tag:BANNER_TAG controller:controller];
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
    [self callbackWithEvent:Yodo1MasAdEventCodeLoaded type:Yodo1MasAdTypeBanner];
}

- (void)adViewDidFailLoading:(YMAAdView *)adView error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: adViewDidFailLoading:error:, id: %@, error: %@}", self.TAG, adView.blockID, error];
    NSLog(@"%@", message);
    self.bannerState = Yodo1MasBannerStateNone;

    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:err type:Yodo1MasAdTypeBanner];
    self.adBanner = nil;
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)adViewWillPresentScreen:(UIViewController *)viewController {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)adViewDidDismissScreen:(UIViewController *)viewController {
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    self.adBanner = nil;
    self.bannerState = Yodo1MasBannerStateNone;
    [self loadBannerAd];
}

//#pragma mark YMAInterstitialDelegate //API Version 3.x
//
//-(void)interstitialAdDidLoad:(YMAInterstitialAd *)interstitialAd {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialAdDidLoad:, placementId: %@}", self.TAG, interstitialAd.blockID];
//    NSLog(@"%@", message);
//}
//
//- (void)interstitialAdDidFailToLoad:(YMAInterstitialAd *)interstitialAd error:(NSError *)error {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialAdDidFailToLoad:, placementId: %@}", self.TAG, interstitialAd.blockID];
//    NSLog(@"%@", message);
//    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
//    [self callbackWithError:err type:Yodo1MasAdTypeInterstitial];
//    [self nextInterstitial];
//    [self loadInterstitialAdDelayed];
//}
//
//- (void)interstitialDidAppear:(YMAInterstitialAd *)interstitialAd {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidAppear:, placementId: %@}", self.TAG, interstitialAd.blockID];
//    NSLog(@"%@", message);
//    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
//}
//
//- (void)interstitialDidDisappear:(YMAInterstitialAd *)interstitialAd {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidDisappear:, placementId: %@}", self.TAG, interstitialAd.blockID];
//    NSLog(@"%@", message);
//    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
//}
//

#pragma mark YMAInterstitialDelegate //API Version 2.x

- (void)interstitialDidLoadAd:(YMAInterstitialController *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialAdDidLoad:, placementId: %@}", self.TAG, interstitial.blockID];
    NSLog(@"%@", message);
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidFailToLoadAd:(YMAInterstitialController *)interstitial error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialAdDidFailToLoad:, placementId: %@}", self.TAG, interstitial.blockID];
    NSLog(@"%@", message);
    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:err type:Yodo1MasAdTypeInterstitial];
    self.interstitialAd = nil;
    [self nextInterstitial];
    [self loadInterstitialAdDelayed];
}

- (void)interstitialDidFailToPresentAd:(YMAInterstitialController *)interstitial error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToPresentAd:error:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *yandexError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:yandexError type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidAppear:(YMAInterstitialController *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidAppear:, placementId: %@}", self.TAG, interstitial.blockID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidDisappear:(YMAInterstitialController *)interstitial {
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidDisappear:, placementId: %@}", self.TAG, interstitial.blockID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
    [self loadInterstitialAd];
}

#pragma mark - YMARewardedAdDelegate

- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:didReward:, placementId: %@}", self.TAG, rewardedAd.blockID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
}

- (void)rewardedAdDidLoadAd:(YMARewardedAd *)rewardedAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidLoadAd:, placementId: %@}", self.TAG, rewardedAd.blockID];
    NSLog(@"%@", message);
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)rewardedAdDidFailToLoadAd:(YMARewardedAd *)rewardedAd error:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidFailToLoadAd:, placementId: %@}", self.TAG, rewardedAd.blockID];
    NSLog(@"%@", message);

    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:err type:Yodo1MasAdTypeReward];
    self.rewardVideoAd = nil;
    [self nextReward];
    [self loadRewardAdDelayed];
}

- (void)rewardedAdDidDisappear:(YMARewardedAd *)rewardedAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidDisappear:, placementId: %@}", self.TAG, rewardedAd.blockID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self loadRewardAd];
}

- (void)rewardedAd:(YMARewardedAd *)rewardedAd willPresentScreen:(UIViewController *)viewController {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:willPresentScreen:, placementId: %@}", self.TAG, rewardedAd.blockID];
    NSLog(@"%@", message);
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

@end
