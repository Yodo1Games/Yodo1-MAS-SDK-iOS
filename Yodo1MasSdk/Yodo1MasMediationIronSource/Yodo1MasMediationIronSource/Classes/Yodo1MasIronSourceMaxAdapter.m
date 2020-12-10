//
//  Yodo1MasIronSourceMaxAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasIronSourceMaxAdapter.h"
#import <IronSource/IronSource.h>

@interface Yodo1MasIronSourceMaxAdapter()<ISRewardedVideoDelegate, ISInterstitialDelegate, ISBannerDelegate>

@property (nonatomic, assign) BOOL sdkInit;

@end

@implementation Yodo1MasIronSourceMaxAdapter

- (NSString *)advertCode {
    return @"IronSourceMax";
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
        [IronSource setRewardedVideoDelegate:self];
        [IronSource setInterstitialDelegate:self];
        [IronSource setBannerDelegate:self];
        [IronSource initWithAppKey:config.appKey adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_BANNER]];
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
    return [IronSource hasRewardedVideo];
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    [IronSource loadInterstitial];
}

#pragma mark - ISRewardedVideoDelegate
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    
}

- (void)rewardedVideoDidOpen {
    
}

- (void)rewardedVideoDidClose {
    
}

- (void)rewardedVideoDidStart {
    
}

- (void)rewardedVideoDidEnd {
    
}

- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
    
}

#pragma mark - ISInterstitialDelegate
- (void)interstitialDidLoad {
    
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error {
    
}

- (void)interstitialDidOpen {
    
}

- (void)interstitialDidClose {
    
}

- (void)interstitialDidShow {
    
}

- (void)interstitialDidFailToShowWithError:(NSError *)error {
    
}

- (void)didClickInterstitial {
    
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
