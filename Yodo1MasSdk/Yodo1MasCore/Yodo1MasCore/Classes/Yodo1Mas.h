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

typedef enum {
    Yodo1MasAdvertTypeReward,
    Yodo1MasAdvertTypeInterstitial,
    Yodo1MasAdvertTypeBanner
} Yodo1MasAdvertType;

typedef enum {
    Yodo1MasAdvertEventOpened,
    Yodo1MasAdvertEventClosed,
    Yodo1MasAdvertEventError,
    Yodo1MasAdvertEventRewardEarned
} Yodo1MasAdvertEvent;

typedef void(^Yodo1MasAdvertCallback) (Yodo1MasAdvertEvent, NSError *);

@interface Yodo1Mas : NSObject

@property(nonatomic, assign) BOOL coppaRestricted;
@property(nonatomic, assign) BOOL gdprReject;
@property(nonatomic, assign) BOOL ccpaReject;

+ (Yodo1Mas *)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail;

- (BOOL)isRewardAdvertLoaded;
- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback;

- (BOOL)isInterstitialAdvertLoaded;
- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback;

- (BOOL)isBannerAdvertLoaded;
- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback;

@end

NS_ASSUME_NONNULL_END
