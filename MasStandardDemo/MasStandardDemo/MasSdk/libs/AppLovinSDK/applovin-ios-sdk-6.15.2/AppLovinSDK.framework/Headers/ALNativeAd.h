//
//  ALNativeAd.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALPostbackDelegate.h"

NS_ASSUME_NONNULL_BEGIN

__deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.")
@interface ALNativeAd : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@interface ALNativeAd(ALDeprecated)
@property (strong, nonatomic, readonly) NSNumber *adIdNumber __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (copy, nonatomic, readonly, nullable) NSString *zoneIdentifier __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (copy, nonatomic, readonly, nullable) NSString *title __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (copy, nonatomic, readonly, nullable) NSString *descriptionText __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (copy, nonatomic, readonly, nullable) NSString *captionText __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (copy, nonatomic, readonly, nullable) NSString *ctaText __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (strong, nonatomic, readonly, nullable) NSURL *iconURL __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (strong, nonatomic, readonly, nullable) NSURL *imageURL __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (strong, nonatomic, readonly, nullable) NSNumber *starRating __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (strong, nonatomic, readonly, nullable) NSURL *videoURL __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
- (void)trackImpression __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
- (void)trackImpressionAndNotify:(nullable id<ALPostbackDelegate>)postbackDelegate __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (strong, nonatomic, readonly, nullable) NSURL *videoStartTrackingURL __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
- (nullable NSURL *)videoEndTrackingURL:(NSUInteger)percentViewed firstPlay:(BOOL)firstPlay __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (assign, atomic, readonly, getter=isImagePrecached) BOOL imagePrecached __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
@property (assign, atomic, readonly, getter=isVideoPrecached) BOOL videoPrecached __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");
- (void)launchClickTarget __deprecated_msg("Native ads have been deprecated and will be removed in a future SDK version.");

@end

NS_ASSUME_NONNULL_END
