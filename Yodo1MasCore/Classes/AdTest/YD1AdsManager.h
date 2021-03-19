#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YD1AdvertConstant.h"


@interface YD1AdsManager : NSObject

+ (YD1AdsManager*)sharedInstance;

- (void)initAdvert;

- (BOOL)isVideoReady;

- (void)videoCallback:(YD1VideoCallback)callback;

- (void)showVideo:(UIViewController *)viewController;

- (BOOL)isInterstitialReady;

- (void)intersCallback:(YD1InterstitialCallback)callback;

- (void)showInterstitial:(UIViewController *)viewController;

- (BOOL)isBannerReady;

- (void)bannerCallback:(YD1BannerCallback)callback;

- (UIView*)bannerView;

@end
