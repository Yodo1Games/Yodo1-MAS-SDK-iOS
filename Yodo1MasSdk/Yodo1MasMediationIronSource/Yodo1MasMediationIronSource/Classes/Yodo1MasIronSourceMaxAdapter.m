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
        
        [self updatePrivacy];
        [self loadRewardAdvert];
        [self loadInterstitialAdvert];
        [self loadBannerAdvert];
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
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        if (controller == nil) {
            controller = [Yodo1MasIronSourceMaxAdapter getTopViewController];
        }
        if (controller != nil) {
            [IronSource showRewardedVideoWithViewController:controller];
        }
    }
}

#pragma mark - ISRewardedVideoDelegate
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)ironSourceError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:ironSourceError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidOpen {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidClose {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidStart {
    
}

- (void)rewardedVideoDidEnd {
    
}

- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return [IronSource hasInterstitial];
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    [IronSource loadInterstitial];
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        if (controller == nil) {
            controller == [Yodo1MasIronSourceMaxAdapter getTopViewController];
        }
        if (controller != nil) {
            [IronSource showInterstitialWithViewController:controller];
        }
    }
}

#pragma mark - ISInterstitialDelegate
- (void)interstitialDidLoad {
    
}

- (void)interstitialDidFailToLoadWithError:(NSError *)ironSourceError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:ironSourceError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidOpen {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidClose {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidShow {
    
}

- (void)interstitialDidFailToShowWithError:(NSError *)ironSourceError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:ironSourceError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
}

- (void)didClickInterstitial {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return NO;
}

- (void)loadBannerAdvert {
    
}

- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:controller callback:callback];
}

#pragma mark - ISBannerDelegate
- (void)bannerDidLoad:(ISBannerView *)bannerView {
    
}

- (void)bannerDidFailToLoadWithError:(NSError *)ironSourceError {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:ironSourceError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeBanner];
}

- (void)didClickBanner {
    
}

- (void)bannerWillPresentScreen {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeBanner];
}

- (void)bannerDidDismissScreen {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeBanner];
}

- (void)bannerWillLeaveApplication {
    
}

@end
