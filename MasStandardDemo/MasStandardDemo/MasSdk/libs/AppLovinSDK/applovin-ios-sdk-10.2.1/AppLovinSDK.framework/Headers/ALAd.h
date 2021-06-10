//
//  ALAd.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

#import "ALAdSize.h"
#import "ALAdType.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents an ad that has been served from the AppLovin server.
 */
@interface ALAd : NSObject<NSCopying>

/**
 * The size of this ad.
 */
@property (nonatomic, strong, readonly) ALAdSize *size;

/**
 * The type of this ad.
 */
@property (nonatomic, strong, readonly) ALAdType *type;

/**
 * The zone id for the ad, if any.
 */
@property (nonatomic, copy, readonly, nullable) NSString *zoneIdentifier;

/**
 * Whether or not the current ad is a video advertisement.
 */
@property (nonatomic, assign, readonly, getter=isVideoAd) BOOL videoAd;

/**
 * Get an arbitrary ad value for a given key. The list of keys may be found in AppLovin documentation online.
 * @param key The designated key to retrieve desired value for.
 *
 * @return An arbitrary ad value for a given key - or nil if does not exist.
 */
- (nullable NSString *)adValueForKey:(NSString *)key;

/**
 * Get an arbitrary ad value for a given key. The list of keys may be found in AppLovin documentation online.
 *
 * @param key The designated key to retrieve desired value for.
 * @param defaultValue The default value to return if the desired value for does not exist or is nil.
 *
 * @return An arbitrary ad value for a given key - or the default value if does not exist.
 */
- (nullable NSString *)adValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

/**
 * A unique ID which identifies this advertisement.
 *
 * Should you need to report a broken ad to AppLovin support, please include this number's longValue.
 */
@property (nonatomic, strong, readonly) NSNumber *adIdNumber;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
