//
//  Yodo1MasAdapterBase.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1Mas.h"
#import "Yodo1MasBanner.h"

NS_ASSUME_NONNULL_BEGIN

#define DelayTime 120
#define kArgumentPlacement        @"arg_placement"
#define kArgumentBannerAlign      @"arg_banner_align"
#define kArgumentBannerOffset     @"arg_banner_offset"

typedef void(^Yodo1MasAdapterInitSuccessful)(NSString *);
typedef void(^Yodo1MasAdapterInitFail)(NSString *, NSError *);

@interface Yodo1MasAdapterConfig : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appKey;

@end

@interface Yodo1MasAdId : NSObject

@property (nonatomic, copy) NSString *adId;
@property (nonatomic, strong) id object;

- (instancetype)initWitId:(NSString *)adId object:(id)object;

@end

@interface Yodo1MasAdapterBase : NSObject

@property (nonatomic, copy, readonly) NSString *advertCode;
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@property (nonatomic, copy, readonly) NSString *mediationVersion;

@property (nonatomic, strong) NSMutableArray<Yodo1MasAdId *> *rewardAdIds;
@property (nonatomic, strong) NSMutableArray<Yodo1MasAdId *> *interstitialAdIds;
@property (nonatomic, strong) NSMutableArray<Yodo1MasAdId *> *bannerAdIds;

@property (nonatomic, copy, readonly) Yodo1MasAdapterInitSuccessful initSuccessfulCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdapterInitFail initFailCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdCallback rewardCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdCallback interstitialCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdCallback bannerCallback;

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail;
- (BOOL)isInitSDK;
- (void)updatePrivacy;

- (void)nextReward;
- (Yodo1MasAdId *)getRewardAdId;
- (void)nextInterstitial;
- (Yodo1MasAdId *)getInterstitialAdId;
- (void)nextBanner;
- (Yodo1MasAdId *)getBannerAdId;

- (BOOL)isAdLoaded:(Yodo1MasAdType)type;
- (void)loadAd:(Yodo1MasAdType)type;
- (void)loadAdDelayed:(Yodo1MasAdType)type;
- (void)showAd:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (BOOL)isCanShow:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback;
- (void)callbackWithEvent:(Yodo1MasAdEventCode)code type:(Yodo1MasAdType)type;
- (void)callbackWithError:(Yodo1MasError *)error type:(Yodo1MasAdType)type;

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded;
- (void)loadRewardAd;
- (void)loadRewardAdDelayed;
- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (void)dismissRewardAd;

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded;
- (void)loadInterstitialAd;
- (void)loadInterstitialAdDelayed;
- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (void)dismissInterstitialAd;

#pragma mark - 插屏广告
- (BOOL)isBannerAdLoaded;
- (void)loadBannerAd;
- (void)loadBannerAdDelayed;
- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (void)dismissBannerAd;

+ (UIWindow *)getTopWindow;
+ (UIViewController *)getTopViewController;

@end

NS_ASSUME_NONNULL_END
