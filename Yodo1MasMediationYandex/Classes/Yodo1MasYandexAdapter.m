//
//  Yodo1MasYandexAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasYandexAdapter.h"

@interface Yodo1MasYandexAdapter()

@end

@implementation Yodo1MasYandexAdapter

- (NSString *)advertCode {
    return @"Yandex";
}

- (NSString *)sdkVersion {
    return @"1.0.0";
}

- (NSString *)mediationVersion {
    return @"4.0.0.6";
}

-(void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail  {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    return [super isInitSDK];
}

- (void)updatePrivacy {
    [super updatePrivacy];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    return [super isRewardAdLoaded];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
        if (controller != nil) {
            
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    return [super isInterstitialAdLoaded];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasYandexAdapter getTopViewController];
        if (controller != nil) {
            
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    [super isBannerAdLoaded];
    return NO;
}

- (void)loadBannerAd {
    [super loadBannerAd];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        
    }
}

@end
