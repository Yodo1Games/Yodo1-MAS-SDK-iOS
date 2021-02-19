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

//@property(nonatomic,strong) YMAAdView           * adBanner;
//@property(nonatomic,strong) YMAInterstitialAd   * interstitialAd;
//@property(nonatomic,strong) YMARewardedAd       * rewardVideoAd;
//@property(nonatomic,assign) BOOL isYMSDKInit;

@end

@implementation Yodo1MasYandexAdapter

//- (YMAAdView *)adBanner {
//    if (!_adBanner) {
//        CGSize size = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YMAAdSizeBanner_320x50 : YMAAdSizeBanner_728x90;
//        YMAAdSize * adSize = [YMAAdSize flexibleSizeWithCGSize:size];
//        _adBanner = [[YMAAdView alloc] initWithBlockID:[self getBannerAdId].adId adSize:adSize];
//        _adBanner.delegate = self;
//    }
//    return _adBanner;
//}
//
//-(YMAInterstitialAd *)interstitialAd {
//    if (!_interstitialAd) {
//        _interstitialAd = [[YMAInterstitialAd alloc] initWithBlockID:[self getInterstitialAdId].adId];
//        _interstitialAd.delegate = self;
//    }
//    return _interstitialAd;
//}
//
//-(YMARewardedAd *)rewardVideoAd {
//    if (!_rewardVideoAd) {
//        _rewardVideoAd = [[YMARewardedAd alloc] initWithBlockID:[self getRewardAdId].adId];
//        _rewardVideoAd.delegate = self;
//    }
//    return _rewardVideoAd;
//}

- (NSString *)advertCode {
    return @"Yandex";
}

- (NSString *)sdkVersion {
    return [YMAMobileAds SDKVersion];
}

- (NSString *)mediationVersion {
    return @"4.0.0.6";
}

//-(void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail  {
//    [super initWithConfig:config successful:successful fail:fail];
//
//    if (![self isInitSDK]) {
//        [self updatePrivacy];
//        [self loadBannerAd];
//        [self loadInterstitialAd];
//        [self loadRewardAd];
//        if (!successful) {
//            successful(self.advertCode);
//        }
//        self.isYMSDKInit = YES;
//    } else {
//        if (successful != nil) {
//            successful(self.advertCode);
//        }
//    }
//}
//
//- (BOOL)isInitSDK {
//    [super isInitSDK];
//    return self.isYMSDKInit;
//}
//
//- (void)updatePrivacy {
//    [super updatePrivacy];
//    [YMAMobileAds setUserConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
//}
//
//#pragma mark - 激励广告
//- (BOOL)isRewardAdLoaded {
//    [super isRewardAdLoaded];
//    if (![self isInitSDK]) {return NO;}
//    return self.rewardVideoAd.loaded;
//}
//
//- (void)loadRewardAd {
//    if ([self isRewardAdLoaded]) {
//        [super loadRewardAd];
//        NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", self.TAG];
//        NSLog(@"%@", message);
//        [self.rewardVideoAd load];
//    }
//}
//
//- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
//    [super showRewardAd:callback object:object];
//    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
//        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
//        if (controller != nil) {
//            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd, show reward ad...}", self.TAG];
//            NSLog(@"%@", message);
//            [self.rewardVideoAd presentFromViewController:controller];
//        }
//    }
//}
//
//#pragma mark - 插屏广告
//- (BOOL)isInterstitialAdLoaded {
//    [super isInterstitialAdLoaded];
//    if ([self isInitSDK]) {
//        return self.interstitialAd.loaded && !self.interstitialAd.hasBeenPresented;
//    }
//    return NO;
//}
//
//- (void)loadInterstitialAd {
//    if (![self isInterstitialAdLoaded]) {
//        [super loadInterstitialAd];
//        [self.interstitialAd load];
//    }
//}
//
//- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
//    [super showInterstitialAd:callback object:object];
//    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
//        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
//        if (controller != nil) {
//            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd, show interstitial ad...}", self.TAG];
//            NSLog(@"%@", message);
//            [self.interstitialAd presentFromViewController:controller];
//        }
//    }
//}
//
//#pragma mark - 横幅广告
//- (BOOL)isBannerAdLoaded {
//    [super isBannerAdLoaded];
//    if ([self isInitSDK]) {
//        return self.adBanner;
//    }
//    return NO;
//}
//
//- (void)loadBannerAd {
//    if (![self isBannerAdLoaded]) {
//        [super loadBannerAd];
//        [self.adBanner loadAd];
//        self.bannerState = Yodo1MasBannerStateLoading;
//    }
//}
//
//- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
//    [super showBannerAd:callback object:object];
//    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
//        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
//        [Yodo1MasBanner showBannerWithTag:BANNER_TAG controller:controller object:object];
//    }
//}
//
//#pragma mark YMAAdViewDelegate
//
//- (void)adViewDidLoad:(YMAAdView *)adView {
//    NSLog(@"%@: {method: %s",self.TAG,__func__);
//    self.bannerState = Yodo1MasBannerStateLoaded;
//}
//
//- (void)adViewDidFailLoading:(YMAAdView *)adView error:(NSError *)error {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: adViewDidFailLoading:error:, id: %@, error: %@}", self.TAG, adView.blockID, error];
//    NSLog(@"%@", message);
//    self.bannerState = Yodo1MasBannerStateNone;
//
//    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
//    [self callbackWithError:err type:Yodo1MasAdTypeBanner];
//    [self nextBanner];
//    [self loadBannerAdDelayed];
//}
//
//- (void)adViewWillPresentScreen:(UIViewController *)viewController {
//    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
//}
//
//- (void)adViewDidDismissScreen:(UIViewController *)viewController {
//    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
//}
//
//#pragma mark YMAInterstitialDelegate
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
//#pragma mark - YMARewardedAdDelegate
//
//- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:didReward:, placementId: %@}", self.TAG, rewardedAd.blockID];
//    NSLog(@"%@", message);
//    [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
//}
//
//- (void)rewardedAdDidLoadAd:(YMARewardedAd *)rewardedAd {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidLoadAd:, placementId: %@}", self.TAG, rewardedAd.blockID];
//    NSLog(@"%@", message);
//}
//
//- (void)rewardedAdDidFailToLoadAd:(YMARewardedAd *)rewardedAd error:(NSError *)error {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidFailToLoadAd:, placementId: %@}", self.TAG, rewardedAd.blockID];
//    NSLog(@"%@", message);
//
//    Yodo1MasError *err = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
//    [self callbackWithError:err type:Yodo1MasAdTypeReward];
//    [self nextReward];
//    [self loadRewardAdDelayed];
//}
//
//- (void)rewardedAdDidDisappear:(YMARewardedAd *)rewardedAd {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAdDidDisappear:, placementId: %@}", self.TAG, rewardedAd.blockID];
//    NSLog(@"%@", message);
//    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
//}
//
//- (void)rewardedAd:(YMARewardedAd *)rewardedAd willPresentScreen:(UIViewController *)viewController {
//    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedAd:willPresentScreen:, placementId: %@}", self.TAG, rewardedAd.blockID];
//    NSLog(@"%@", message);
//    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
//}


@end
