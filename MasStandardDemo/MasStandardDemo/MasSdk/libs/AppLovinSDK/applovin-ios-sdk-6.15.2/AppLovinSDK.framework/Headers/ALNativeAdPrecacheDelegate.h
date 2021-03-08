//
//  ALNativeAdPrecacheDelegate.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

@class ALNativeAdService;

__deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.")
@protocol ALNativeAdPrecacheDelegate <NSObject>

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheImagesForAd:(ALNativeAd *)ad;
- (void)nativeAdService:(ALNativeAdService *)service didPrecacheVideoForAd:(ALNativeAd *)ad;
- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheImagesForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode;
- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheVideoForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode;

@end

NS_ASSUME_NONNULL_END
