//
//  Yodo1MasFyberAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasFyberAdapter.h"
#import <FairBidSDK/FairBidSDK.h>

#define BANNER_TAG 10012

@interface Yodo1MasFyberAdapter()<FYBRewardedDelegate,FYBInterstitialDelegate,FYBBannerDelegate>


@property(nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) FYBBannerAdView *bannerAd;

@end

@implementation Yodo1MasFyberAdapter

- (NSString *)advertCode {
    return @"fyber";
}

- (NSString *)sdkVersion {
    return FairBid.version;
}

- (NSString *)mediationVersion {
    return @"4.2.0.4201";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [self updatePrivacy];
        [FairBid startWithAppId:config.appId];
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
    [FairBid user].GDPRConsent = [Yodo1Mas sharedInstance].isGDPRUserConsent;
    FairBid.user.IABUSPrivacyString =  @"1YNN";
}


#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return [FYBRewarded isAvailable:[self getRewardAdId].adId ? : @""];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getRewardAdId];
    if (adId) {
        FYBRewarded.delegate = self;
        [FYBRewarded request:adId.adId];
    }
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasFyberAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [FYBRewarded show:[self getRewardAdId].adId];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告

- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return [FYBInterstitial isAvailable:[self getInterstitialAdId].adId ? : @""];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getInterstitialAdId];
    if (adId) {
        FYBInterstitial.delegate = self;
        [FYBInterstitial request:adId.adId];
    }
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasFyberAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [FYBInterstitial show:[self getInterstitialAdId].adId ? : @""];
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    return [super isBannerAdLoaded];
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getBannerAdId];
    
    FYBBanner.delegate = self;
    FYBBannerOptions *bannerOptions = [[FYBBannerOptions alloc] init];
    bannerOptions.placementId = adId.adId;
    [FYBBanner showBannerInView:[Yodo1MasFyberAdapter getTopViewController].view
                       position:FYBBannerAdViewPositionBottom
                        options:bannerOptions];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    [Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        //self.bannerAd = nil;
        [FYBBanner destroy:[self getBannerAdId].adId];
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}

#pragma mark- FYBRewardedDelegate

- (void)rewardedIsAvailable:(nonnull NSString *)placementId {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
}

- (void)rewardedIsUnavailable:(nonnull NSString *)placementId {
    
}

- (void)rewardedDidShow:(nonnull NSString *)placementId impressionData:(nonnull FYBImpressionData *)impressionData {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedDidFailToShow:(nonnull NSString *)placementId withError:(nonnull NSError *)error impressionData:(nonnull FYBImpressionData *)impressionData {
    NSString *message = [NSString stringWithFormat:@"%@: {method: rewardedDidFailToShow:withError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *fyberError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:fyberError type:Yodo1MasAdTypeReward];
}

- (void)rewardedDidClick:(nonnull NSString *)placementId {
    
}

- (void)rewardedDidDismiss:(nonnull NSString *)placementId {
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedDidComplete:(nonnull NSString *)placementId userRewarded:(BOOL)userRewarded {
    if (userRewarded) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

- (void)rewardedWillRequest:(nonnull NSString *)placementId {
    
}

#pragma mark - FYBInterstitialDelegate

- (void)interstitialIsAvailable:(NSString *)placementId {
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialIsUnavailable:(NSString *)placementId {
}

- (void)interstitialDidShow:(NSString *)placementId impressionData:(FYBImpressionData *)impressionData {
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidFailToShow:(NSString *)placementId withError:(NSError *)error impressionData:(FYBImpressionData *)impressionData {
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: interstitialDidFailToShow:withError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *fyberError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdShowFail message:message];
    [self callbackWithError:fyberError type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialDidClick:(NSString *)placementId {
    
}

- (void)interstitialDidDismiss:(NSString *)placementId {
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
}

- (void)interstitialWillRequest:(NSString *)placementId {
    
}

#pragma mark- FYBBannerDelegate

- (void)bannerDidLoad:(FYBBannerAdView *)banner {
    self.bannerAd = banner;
    [self callbackWithAdLoadSuccess:Yodo1MasAdTypeBanner];
    [self callbackWithEvent:Yodo1MasAdEventCodeLoaded type:Yodo1MasAdTypeBanner];
}

- (void)bannerDidFailToLoad:(NSString *)placementId withError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@: {method: bannerDidFailToLoad:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *fyberError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:fyberError type:Yodo1MasAdTypeBanner];
    [self nextBanner];
    [self loadBannerAdDelayed];
}

- (void)bannerDidShow:(FYBBannerAdView *)banner impressionData:(FYBImpressionData *)impressionData {
    
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
}

- (void)bannerDidClick:(FYBBannerAdView *)banner {
    
}

- (void)bannerWillPresentModalView:(FYBBannerAdView *)banner {
    
}

- (void)bannerDidDismissModalView:(FYBBannerAdView *)banner {
    
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
    [self loadBannerAd];
}

- (void)bannerWillLeaveApplication:(FYBBannerAdView *)banner {
    
}

- (void)banner:(FYBBannerAdView *)banner didResizeToFrame:(CGRect)frame {
    
}

- (void)bannerWillRequest:(NSString *)placementId {
    
}

@end
