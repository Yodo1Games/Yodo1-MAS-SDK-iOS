//
//  MTRGBaseAd.h
//  myTargetSDK 5.9.11
//
// Created by Timur on 2/1/18.
// Copyright (c) 2018 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTRGCustomParams;

NS_ASSUME_NONNULL_BEGIN

@interface MTRGBaseAd : NSObject

@property(nonatomic, readonly) MTRGCustomParams *customParams;
@property(nonatomic) BOOL trackLocationEnabled;

+ (void)setDebugMode:(BOOL)enabled;

+ (BOOL)isDebugMode;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)withTestDevices:(nullable NSArray<NSString *> *)testDevices NS_SWIFT_NAME(withTestDevices(_:));

@end

NS_ASSUME_NONNULL_END
