//
//  Yodo1MasAdapterBase.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1Mas.h"

NS_ASSUME_NONNULL_BEGIN

#define DelayTime 120

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
@property (nonatomic, copy, readonly) Yodo1MasAdvertCallback rewardCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdvertCallback interstitialCallback;
@property (nonatomic, copy, readonly) Yodo1MasAdvertCallback bannerCallback;

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail;
- (BOOL)isInitSDK;
- (void)updatePrivacy;

- (BOOL)isAdvertLoaded:(Yodo1MasAdvertType)type;
- (void)loadAdvert:(Yodo1MasAdvertType)type;
- (void)loadAdvertDelayed:(Yodo1MasAdvertType)type;
- (void)showAdvert:(Yodo1MasAdvertType)type callback:(Yodo1MasAdvertCallback)callback;
- (BOOL)isCanShow:(Yodo1MasAdvertType)type callback:(Yodo1MasAdvertCallback)callback;
- (void)callbackWithEvent:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type;
- (void)callbackWithError:(Yodo1MasError *)error type:(Yodo1MasAdvertType)type;

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded;
- (void)loadRewardAdvert;
- (void)loadRewardAdvertDelayed;
- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback;

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded;
- (void)loadInterstitialAdvert;
- (void)loadInterstitialAdvertDelayed;
- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback;

#pragma mark - 插屏广告
- (BOOL)isBannerAdvertLoaded;
- (void)loadBannerAdvert;
- (void)loadBannerAdvertDelayed;
- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback;
- (void)dismissBannerAdvert;

+ (UIWindow *)getTopWindow;
+ (UIViewController *)getTopViewController;

@end

NS_ASSUME_NONNULL_END
