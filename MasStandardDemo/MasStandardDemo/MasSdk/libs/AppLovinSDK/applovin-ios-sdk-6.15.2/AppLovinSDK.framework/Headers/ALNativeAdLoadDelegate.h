//
//  ALNativeAdGroupLoadDelegate.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

@class ALNativeAdService;

__deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.")
@protocol ALNativeAdLoadDelegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray * /* of ALNativeAd */) ads;
- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
