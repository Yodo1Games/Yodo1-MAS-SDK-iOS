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

- (void)updatePrivacy {
    [IronSource setConsent:[Yodo1Mas sharedInstance].isGDPRUserConsent];
    [IronSource setMetaDataWithKey:@"do_not_sell" value: [Yodo1Mas sharedInstance].isCCPADoNotSell ? @"YES" : @"NO"];
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

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        
        if (controller != nil) {
            [IronSource showISDemandOnlyRewardedVideo:controller instanceId:self.rewardPlacementId];
        }
    }
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate
- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidClose:(NSString *)instanceId {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)ironSourceError instanceId:(NSString *)instanceId {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:ironSourceError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
}

- (void)rewardedVideoDidClick:(NSString *)instanceId {
    
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
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

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        
        UIViewController *controller = [Yodo1MasIronSourceAdapter getTopViewController];
        
        if (controller != nil) {
            [IronSource showISDemandOnlyRewardedVideo:controller instanceId:self.rewardPlacementId];
        }
    }
}

#pragma mark - ISDemandOnlyInterstitialDelegate
- (void)interstitialDidLoad:(NSString *)instanceId {
    
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    
}

- (void)interstitialDidOpen:(NSString *)instanceId {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidClose:(NSString *)instanceId {
    [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
}

- (void)interstitialDidFailToShowWithError:(NSError *)ironSourceError instanceId:(NSString *)instanceId {
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertShowFail message:ironSourceError.localizedDescription];
    [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
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
