//
//  Yodo1Mas.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1MasAdvertEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^Yodo1MasInitSuccessful)(void);
typedef void (^Yodo1MasInitFail)(Yodo1MasError *);
typedef void (^Yodo1MasAdvertCallback) (Yodo1MasAdvertEvent *);

@protocol Yodo1MasAdvertDelegate <NSObject>

@optional
- (void)onAdvertOpened:(Yodo1MasAdvertEvent *)event;
- (void)onAdvertClosed:(Yodo1MasAdvertEvent *)event;
- (void)onAdvertError:(Yodo1MasAdvertEvent *)event error:(Yodo1MasError *)error;

@end

@protocol Yodo1MasRewardAdvertDelegate <NSObject, Yodo1MasAdvertDelegate>

@optional
- (void)onAdvertRewardEarned:(Yodo1MasAdvertEvent *)event;

@end

@protocol Yodo1MasInterstitialAdvertDelegate <NSObject, Yodo1MasAdvertDelegate>

@end

@protocol Yodo1MasBannerAdvertDelegate <NSObject, Yodo1MasAdvertDelegate>

@end

@interface Yodo1Mas : NSObject

@property (nonatomic, assign) BOOL isGDPRUserConsent;
@property (nonatomic, assign) BOOL isCOPPAAgeRestricted;
@property (nonatomic, assign) BOOL isCCPADoNotSell;
@property (nonatomic, weak) id<Yodo1MasRewardAdvertDelegate> rewardAdvertDelegate;
@property (nonatomic, weak) id<Yodo1MasInterstitialAdvertDelegate> interstitialAdvertDelegate;
@property (nonatomic, weak) id<Yodo1MasBannerAdvertDelegate> bannerAdvertDelegate;

+ (Yodo1Mas *)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail;

- (BOOL)isRewardAdvertLoaded;
- (void)showRewardAdvert;
- (void)showRewardAdvert:(NSString *)placement;
- (void)dismissRewardAdvert;

- (BOOL)isInterstitialAdvertLoaded;
- (void)showInterstitialAdvert;
- (void)showInterstitialAdvert:(NSString *)placement;
- (void)dismissInterstitialAdvert;

- (BOOL)isBannerAdvertLoaded;
- (void)showBannerAdvert;
- (void)showBannerAdvert:(Yodo1MasBannerAlign)align;
- (void)dismissBannerAdvert;

@end

NS_ASSUME_NONNULL_END
