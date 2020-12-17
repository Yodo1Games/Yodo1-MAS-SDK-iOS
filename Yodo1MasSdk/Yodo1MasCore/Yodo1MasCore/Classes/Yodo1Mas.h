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
typedef void (^Yodo1MasInitFail)(NSError *);
typedef void (^Yodo1MasAdvertCallback) (Yodo1MasAdvertEvent *);

@interface Yodo1Mas : NSObject

@property (nonatomic, assign) BOOL isGDPRUserConsent;
@property (nonatomic, assign) BOOL isCOPPAAgeRestricted;
@property (nonatomic, assign) BOOL isCCPADoNotSell;

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
