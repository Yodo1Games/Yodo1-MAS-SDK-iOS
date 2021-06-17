//
//  Yodo1MasBannerConfig.h
//  Yodo1MasCore
//
//  Created by yanpeng on 2021/5/7.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasBannerConfig : NSObject

@property (nonatomic, assign) BOOL isAdaptiveBanner;
@property (nonatomic, assign) CGFloat bannerWidth;

+ (instancetype)instance;
+ (void)updateConfig:(Yodo1MasBannerConfig *)config;

@end

NS_ASSUME_NONNULL_END
