//
//  Yodo1Ads.m
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1Ads.h"

static Yodo1AdsEventCallback s_bannerCallback;

static Yodo1AdsEventCallback s_interstitialCallback;

static Yodo1AdsEventCallback s_videoCallback;

static Yodo1AdsBannerAdAlign s_bannerAlign = Yodo1AdsBannerAdAlignBottom | Yodo1AdsBannerAdAlignHorizontalCenter;

static CGPoint s_bannerOffset;

@interface Yodo1AdsDelegate : NSObject

@end

@interface Yodo1AdsDelegate()<Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate>

@end

@implementation Yodo1AdsDelegate

#pragma mark - Yodo1MasAdDelegate
- (void)onAdOpened:(Yodo1MasAdEvent *)event {
    switch (event.type) {
        case Yodo1MasAdTypeReward: {
            if (s_videoCallback != nil) {
                s_videoCallback(Yodo1AdsEventShowSuccess, nil);
            }
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            if (s_interstitialCallback != nil) {
                s_interstitialCallback(Yodo1AdsEventShowSuccess, nil);
            }
            break;
        }
        case Yodo1MasAdTypeBanner: {
            if (s_bannerCallback != nil) {
                s_bannerCallback(Yodo1AdsEventShowSuccess, nil);
            }
            break;
        }
    }
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
    switch (event.type) {
        case Yodo1MasAdTypeReward: {
            if (s_videoCallback != nil) {
                s_videoCallback(Yodo1AdsEventClose, nil);
            }
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            if (s_interstitialCallback != nil) {
                s_interstitialCallback(Yodo1AdsEventClose, nil);
            }
            break;
        }
        case Yodo1MasAdTypeBanner: {
            if (s_bannerCallback != nil) {
                s_bannerCallback(Yodo1AdsEventClose, nil);
            }
            break;
        }
    }
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    switch (event.type) {
        case Yodo1MasAdTypeReward: {
            if (s_videoCallback != nil) {
                s_videoCallback(Yodo1AdsEventShowFail, error);
            }
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            if (s_interstitialCallback != nil) {
                s_interstitialCallback(Yodo1AdsEventShowFail, error);
            }
            break;
        }
        case Yodo1MasAdTypeBanner: {
            if (s_bannerCallback != nil) {
                s_bannerCallback(Yodo1AdsEventShowFail, error);
            }
            break;
        }
    }
}

#pragma mark - Yodo1MasRewardAdvertDelegate
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    if (s_videoCallback != nil) {
        s_videoCallback(Yodo1AdsEventFinish, nil);
    }
}

@end

static Yodo1AdsDelegate *delegate;

@implementation Yodo1Ads

+ (NSString *)sdkVersion {
    return [Yodo1Mas sdkVersion];
}


+ (void)initWithAppKey:(NSString *)appKey {
    delegate = [[Yodo1AdsDelegate alloc] init];
    [Yodo1Mas sharedInstance].rewardAdDelegate = delegate;
    [Yodo1Mas sharedInstance].interstitialAdDelegate = delegate;
    [Yodo1Mas sharedInstance].bannerAdDelegate = delegate;
    [[Yodo1Mas sharedInstance] initWithAppId:appKey successful:nil fail:nil];
}

+ (void)setBannerCallback:(Yodo1AdsEventCallback)callback {
    s_bannerCallback = callback;
}

+ (void)setBannerAlign:(Yodo1AdsBannerAdAlign)align {
    s_bannerAlign = align;
}

+ (void)setBannerAlign:(Yodo1AdsBannerAdAlign)align viewcontroller:(UIViewController *)viewcontroller {
    s_bannerAlign = align;
}

+ (void)setBannerOffset:(CGPoint)point {
    s_bannerOffset = point;
}

+ (void)setBannerScale:(CGFloat)sx sy:(CGFloat)sy {
    
}

+ (BOOL)bannerIsReady {
    return [[Yodo1Mas sharedInstance] isBannerAdLoaded];
}

+ (void)showBanner {
    Yodo1MasAdBannerAlign align = s_bannerAlign;
    CGPoint offset = s_bannerOffset;
    [[Yodo1Mas sharedInstance] showBannerAdWithAlign:align offset:offset];
}

+ (void)showBanner:(NSString *)placement_id {
    Yodo1MasAdBannerAlign align = s_bannerAlign;
    CGPoint offset = s_bannerOffset;
    [[Yodo1Mas sharedInstance] showBannerAdWithPlacement:placement_id align:nil offset:offset];
}

+ (void)hideBanner {
    [[Yodo1Mas sharedInstance] dismissBannerAd];
}

+ (void)removeBanner {
    [[Yodo1Mas sharedInstance] dismissBannerAd];
}


+ (void)setInterstitialCallback:(Yodo1AdsEventCallback)callback {
    s_interstitialCallback = callback;
}

+ (BOOL)interstitialIsReady {
    return [[Yodo1Mas sharedInstance] isInterstitialAdLoaded];
}

+ (void)showInterstitial {
    [[Yodo1Mas sharedInstance] showInterstitialAd];
}

+ (void)showInterstitialWithPlacement:(NSString *)placement_id {
    [[Yodo1Mas sharedInstance] showInterstitialAdWithPlacement:placement_id];
}

+ (void)showInterstitial:(UIViewController*)viewcontroller {
    [[Yodo1Mas sharedInstance] showInterstitialAd];
}

+ (void)showInterstitial:(UIViewController *)viewcontroller placement:(NSString *)placement_id {
    [[Yodo1Mas sharedInstance] showInterstitialAdWithPlacement:placement_id];
}

+ (void)setVideoCallback:(Yodo1AdsEventCallback)callback {
    s_videoCallback = callback;
}

+ (BOOL)videoIsReady {
    [[Yodo1Mas sharedInstance] isRewardAdLoaded];
}

+ (void)showVideo {
    [[Yodo1Mas sharedInstance] showRewardAd];
}

+ (void)showVideoWithPlacement:(NSString *)placement_id {
    [[Yodo1Mas sharedInstance] showRewardAdWithPlacement:placement_id];
}

+ (void)showVideo:(UIViewController *)viewcontroller {
    [[Yodo1Mas sharedInstance] showRewardAd];
}

+ (void)showVideo:(UIViewController *)viewcontroller placement:(NSString *)placement_id {
    [[Yodo1Mas sharedInstance] showRewardAdWithPlacement:placement_id];
}

+ (void)setUserConsent:(BOOL)consent {
    [Yodo1Mas sharedInstance].isGDPRUserConsent = consent;
}

+ (BOOL)isUserConsent {
    return [Yodo1Mas sharedInstance].isGDPRUserConsent;
}

+ (void)setTagForUnderAgeOfConsent:(BOOL)isBelowConsentAge {
    [Yodo1Mas sharedInstance].isCOPPAAgeRestricted = isBelowConsentAge;
}

+ (BOOL)isTagForUnderAgeOfConsent {
    return [Yodo1Mas sharedInstance].isCOPPAAgeRestricted;
}

+ (void)setDoNotSell:(BOOL)doNotSell {
    [Yodo1Mas sharedInstance].isCCPADoNotSell = doNotSell;
}

+ (BOOL)isDoNotSell {
    return [Yodo1Mas sharedInstance].isCCPADoNotSell;
}

@end
