//
//  Yodo1MasBannerConfig.m
//  Yodo1MasCore
//
//  Created by yanpeng on 2021/5/7.
//

#import "Yodo1MasBannerConfig.h"

@implementation Yodo1MasBannerConfig

- (CGFloat)bannerWidth {
    if (!_bannerWidth) {
        _bannerWidth = [UIScreen mainScreen].bounds.size.width;
    }
    return _bannerWidth;
}

+ (instancetype)instance {
    static Yodo1MasBannerConfig * _config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[Yodo1MasBannerConfig alloc] init];
    });
    return _config;
}

+ (void)updateConfig:(Yodo1MasBannerConfig *)config {
    [Yodo1MasBannerConfig instance].isAdaptiveBanner = config.isAdaptiveBanner;
    [Yodo1MasBannerConfig instance].bannerWidth = config.bannerWidth;
}

@end
