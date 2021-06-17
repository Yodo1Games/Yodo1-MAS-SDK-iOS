//
//  Yodo1MasBannerConfig.m
//  Yodo1MasCore
//
//  Created by yanpeng on 2021/5/7.
//

#import "Yodo1MasAdBuildConfig.h"

@implementation Yodo1MasAdBuildConfig

+ (instancetype)instance {
    static Yodo1MasAdBuildConfig * _config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[Yodo1MasAdBuildConfig alloc] init];
    });
    return _config;
}

+ (void)updateConfig:(Yodo1MasAdBuildConfig *)config {
    [Yodo1MasAdBuildConfig instance].enableAdaptiveBanner = config.enableAdaptiveBanner;
}

@end
