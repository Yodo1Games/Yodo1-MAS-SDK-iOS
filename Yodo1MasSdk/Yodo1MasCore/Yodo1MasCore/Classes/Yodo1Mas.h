//
//  Yodo1Mas.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Yodo1MasInitSuccessful)();
typedef void (^Yodo1MasInitFail)(NSError *);

@protocol Yodo1MasAdvertDelegate <NSObject>

@optional
- (void)onAdvertShowSuccessful;
- (void)onAdvertShowFail;
- (void)onAdvertClicked;

@end

@protocol Yodo1MasAdvertRewardDelegate<NSObject, Yodo1MasAdvertDelegate>

@optional
- (void)onAdvertRewardEarned;

@end

@protocol Yodo1MasAdvertInterstitialDelegate <NSObject, Yodo1MasAdvertDelegate>

@end

@protocol Yodo1MasAdvertBannerDelegate <NSObject, Yodo1MasAdvertDelegate>

@end

@interface Yodo1Mas : NSObject

@property(nonatomic, assign) BOOL coppaRestricted;
@property(nonatomic, assign) BOOL gdprReject;
@property(nonatomic, assign) BOOL ccpaReject;

+ (Yodo1Mas *)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail;

- (BOOL)isRewardAdvertLoaded;
- (void)showRewardAdvert:(id<Yodo1MasAdvertRewardDelegate>)delegate;

- (BOOL)isInterstitialAdvertLoaded;
- (void)showInterstitialAdvert:(id<Yodo1MasAdvertInterstitialDelegate>)delegate;

- (BOOL)isBannerAdvertLoaded;
- (void)showBannerAdvert:(id<Yodo1MasAdvertBannerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
