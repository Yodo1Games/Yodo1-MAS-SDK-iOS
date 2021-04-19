#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1AdvertConstant.h"


@interface Yodo1AdsManager : NSObject

+ (Yodo1AdsManager*)sharedInstance;

- (void)initAdvert;

- (BOOL)isVideoReady;

- (void)videoCallback:(YD1VideoCallback)callback;

- (void)showVideo:(UIViewController *)viewController;

- (BOOL)isInterstitialReady;

- (void)intersCallback:(YODO1InterstitialCallback)callback;

- (void)showInterstitial:(UIViewController *)viewController;

- (BOOL)isBannerReady;

- (void)bannerCallback:(Yodo1BannerCallback)callback;

- (UIView*)bannerView;

@end
