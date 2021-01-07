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
#define KeyArgumentPlacement      @"arg_placement"
#define KeyArgumentBannerAlign      @"arg_banner_align"

typedef void(^Yodo1MasAdapterInitSuccessful)(NSString *);
typedef void(^Yodo1MasAdapterInitFail)(NSString *, NSError *);

@interface Yodo1MasAdapterConfig : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appKey;

@end

@interface Yodo1MasAdapterBase : NSObject

@property (nonatomic, copy, readonly) NSString *advertCode;
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@property (nonatomic, copy, readonly) NSString *mediationVersion;

@property (nonatomic, copy) NSString *rewardPlacementId;
@property (nonatomic, copy) NSString *interstitialPlacementId;
@property (nonatomic, copy) NSString *bannerPlacementId;

@property (nonatomic, copy, readonly) Yodo1MasAdapterInitSuccessful initSuccessfulCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdapterInitFail initFailCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdCallback rewardCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdCallback interstitialCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdCallback bannerCallback;

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail;
- (BOOL)isInitSDK;
- (void)updatePrivacy;

- (BOOL)isAdvertLoaded:(Yodo1MasAdType)type;
- (void)loadAdvert:(Yodo1MasAdType)type;
- (void)loadAdvertDelayed:(Yodo1MasAdType)type;
- (void)showAdvert:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (BOOL)isCanShow:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback;
- (void)callbackWithEvent:(Yodo1MasAdEventCode)code type:(Yodo1MasAdType)type;
- (void)callbackWithError:(Yodo1MasError *)error type:(Yodo1MasAdType)type;

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded;
- (void)loadRewardAdvert;
- (void)loadRewardAdvertDelayed;
- (void)showRewardAdvert:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (void)dismissRewardAdvert;

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded;
- (void)loadInterstitialAdvert;
- (void)loadInterstitialAdvertDelayed;
- (void)showInterstitialAdvert:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (void)dismissInterstitialAdvert;

#pragma mark - 插屏广告
- (BOOL)isBannerAdvertLoaded;
- (void)loadBannerAdvert;
- (void)loadBannerAdvertDelayed;
- (void)showBannerAdvert:(Yodo1MasAdCallback)callback object:(NSDictionary *)object;
- (void)dismissBannerAdvert;

+ (UIWindow *)getTopWindow;
+ (UIViewController *)getTopViewController;

@end

NS_ASSUME_NONNULL_END
