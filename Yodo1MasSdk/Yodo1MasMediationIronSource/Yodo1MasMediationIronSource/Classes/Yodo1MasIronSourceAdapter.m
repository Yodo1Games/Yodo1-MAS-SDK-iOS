//
//  Yodo1MasIronSourceAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasIronSourceAdapter.h"
#import <IronSource/IronSource.h>

@interface Yodo1MasIronSourceAdapter()<ISDemandOnlyRewardedVideoDelegate, ISDemandOnlyInterstitialDelegate, ISBannerDelegate>

@property (nonatomic, assign) BOOL sdkInit;
@property (nonatomic, strong) ISBannerView *bannerView;

@end

@implementation Yodo1MasIronSourceAdapter

- (NSString *)advertCode {
    return @"IronSource";
}

- (NSString *)sdkVersion {
    return [IronSource sdkVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        self.sdkInit = YES;
        [IronSource setISDemandOnlyRewardedVideoDelegate:self];
        [IronSource setISDemandOnlyInterstitialDelegate:self];
        [IronSource setBannerDelegate:self];
        [IronSource initISDemandOnly:config.appKey adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_BANNER]];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    return self.sdkInit;
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return self.rewardPlacementId != nil && [IronSource hasISDemandOnlyRewardedVideo:self.rewardPlacementId];
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    if (self.rewardPlacementId != nil) {
        [IronSource loadISDemandOnlyRewardedVideo:self.rewardPlacementId];
    }
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:controller callback:callback];
    if ([self isInitSDK]) {
        if ([self isRewardAdvertLoaded]) {
            if (controller == nil) {
                controller = [Yodo1MasIronSourceAdapter getTopViewController];
            }
            if (controller != nil) {
                [IronSource showISDemandOnlyRewardedVideo:controller instanceId:self.rewardPlacementId];
            } else {
                if (callback != nil) {
                    callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
                }
            }
        } else {
            if (callback != nil) {
                callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
            }
        }
    } else {
        if (callback != nil) {
            callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
        }
    }
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate
- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventOpened, nil);
    }
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventClosed, nil);
    }
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
    }
}

- (void)rewardedVideoDidClick:(NSString *)instanceId {
    
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    if (self.rewardCallback != nil) {
        self.rewardCallback(Yodo1MasAdvertEventRewardEarned, nil);
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return self.interstitialPlacementId != nil && [IronSource hasISDemandOnlyInterstitial:self.interstitialPlacementId];
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    if (self.interstitialPlacementId != nil) {
        [IronSource loadISDemandOnlyInterstitial:self.interstitialPlacementId];
    }
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:controller callback:callback];
    if ([self isInitSDK]) {
        if ([self isInterstitialAdvertLoaded]) {
            if (controller == nil) {
                controller = [Yodo1MasIronSourceAdapter getTopViewController];
            }
            if (controller != nil) {
                [IronSource showISDemandOnlyRewardedVideo:controller instanceId:self.rewardPlacementId];
            } else {
                if (callback != nil) {
                    callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
                }
            }
        } else {
            if (callback != nil) {
                callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
            }
        }
    } else {
        if (callback != nil) {
            callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
        }
    }
}

#pragma mark - ISDemandOnlyInterstitialDelegate
- (void)interstitialDidLoad:(NSString *)instanceId {
    
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    
}

- (void)interstitialDidOpen:(NSString *)instanceId {
    if (self.interstitialCallback != nil) {
        self.interstitialCallback(Yodo1MasAdvertEventOpened, nil);
    }
}

- (void)interstitialDidClose:(NSString *)instanceId {
    if (self.interstitialCallback != nil) {
        self.interstitialCallback(Yodo1MasAdvertEventClosed, nil);
    }
}

- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    if (self.interstitialCallback != nil) {
        self.interstitialCallback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
    }
}

- (void)didClickInterstitial:(NSString *)instanceId {
    
}

#pragma mark - 插屏广告
- (BOOL)isBannerAdvertLoaded {
    return YES;
}

#pragma mark - ISBannerDelegate
- (void)bannerDidLoad:(ISBannerView *)bannerView {
    
}

- (void)bannerDidFailToLoadWithError:(NSError *)error {
    
}

- (void)didClickBanner {
    
}

- (void)bannerWillPresentScreen {
    
}

- (void)bannerDidDismissScreen {
    
}

- (void)bannerWillLeaveApplication {
    
}

@end
