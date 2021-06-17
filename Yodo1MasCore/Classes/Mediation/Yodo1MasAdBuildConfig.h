//
//  Yodo1MasBannerConfig.h
//  Yodo1MasCore
//
//  Created by yanpeng on 2021/5/7.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasAdBuildConfig : NSObject

@property (nonatomic, assign) BOOL enableAdaptiveBanner;

+ (instancetype)instance;
+ (void)updateConfig:(Yodo1MasAdBuildConfig *)config;

@end

NS_ASSUME_NONNULL_END
