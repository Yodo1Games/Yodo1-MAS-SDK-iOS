//
//  ALNativeAdService.h
//  AppLovinSDK
//
//  Created by Thomas So on 5/21/15.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALNativeAdLoadDelegate.h"
#import "ALNativeAdPrecacheDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class ALSdk;
@class ALNativeAd;

__deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.")
@interface ALNativeAdService : NSObject

- (instancetype)init __attribute__((unavailable("Access ALNativeAdService through ALSdk's nativeAdService property.")));
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface ALNativeAdService(ALDeprecated)
- (void)loadNativeAdGroupOfCount:(NSUInteger)numberOfAdsToLoad andNotify:(nullable id<ALNativeAdLoadDelegate>)delegate __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
- (void)loadNextAdAndNotify:(id<ALNativeAdLoadDelegate>)delegate __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
- (void)precacheResourcesForNativeAd:(ALNativeAd *)ad andNotify:(nullable id<ALNativeAdPrecacheDelegate>)delegate __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@end

NS_ASSUME_NONNULL_END
