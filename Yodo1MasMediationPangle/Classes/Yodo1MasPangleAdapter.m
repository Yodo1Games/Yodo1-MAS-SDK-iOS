//
//  Yodo1MasPangleAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasPangleAdapter.h"
#import <BUAdSDK/BUAdSDK.h>

#define BANNER_TAG 10011

@interface Yodo1MasPangleAdapter()<BURewardedVideoAdDelegate> {
    BOOL isRewardAdReady;
    BOOL isInterstitialAdReady;
}


@property(nonatomic, assign) BOOL sdkInit;
//@property (nonatomic, strong) MTRGAdView *bannerAd;
//@property (nonatomic, strong) MTRGInterstitialAd *interstitialAd;
@property (nonatomic, strong) BURewardedVideoAd *rewardAd;
@property (nonatomic,strong) BURewardedVideoModel *rewardModel;

@end

@implementation Yodo1MasPangleAdapter

- (NSString *)advertCode {
    return @"pangle";
}

- (NSString *)sdkVersion {
    return BUAdSDKManager.SDKVersion;
}

- (NSString *)mediationVersion {
    return @"4.0.1.0";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [self updatePrivacy];
        [BUAdSDKManager setAppID:config.appId];
        [BUAdSDKManager setIsPaidApp:NO];
        self.sdkInit = YES;
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return self.sdkInit;
}

- (void)updatePrivacy {
    [super updatePrivacy];
    [BUAdSDKManager setGDPR:Yodo1Mas.sharedInstance.isGDPRUserConsent];
    [BUAdSDKManager setCoppa:Yodo1Mas.sharedInstance.isCOPPAAgeRestricted];
}


#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return isRewardAdReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    [self.rewardAd loadAdData];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [self.rewardAd showAdFromRootViewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
}

- (BURewardedVideoAd *)rewardAd {
    if (!_rewardAd) {
       _rewardModel = [[BURewardedVideoModel alloc] init];
        _rewardModel.userId = @"";
        Yodo1MasAdId *adId = [self getRewardAdId];
        _rewardAd = [[BURewardedVideoAd alloc] initWithSlotID:adId.adId
                                           rewardedVideoModel:_rewardModel];
        _rewardAd.delegate = self;
    }
    return _rewardAd;
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
        
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
        }
    }
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    return [super isBannerAdLoaded];
}

- (void)loadBannerAd {
    [super loadBannerAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getBannerAdId];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showBannerAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeBanner callback:callback]) {
        NSString *message = [NSString stringWithFormat:@"%@: {method:showBannerAd:, show banner ad...}", self.TAG];
        NSLog(@"%@", message);
        
        UIViewController *controller = [Yodo1MasPangleAdapter getTopViewController];
        if (controller != nil) {
            
        }
        [Yodo1MasBanner showBannerWithTag:BANNER_TAG controller:controller object:object];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    [super dismissBannerAdWithDestroy:destroy];
    //[Yodo1MasBanner removeBanner:self.bannerAd tag:BANNER_TAG destroy:destroy];
    if (destroy) {
        //self.bannerAd = nil;
        self.bannerState = Yodo1MasBannerStateNone;
        [self loadBannerAd];
    }
}


#pragma mark BURewardedVideoAdDelegate

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    isRewardAdReady = YES;
}


- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    isRewardAdReady = NO;
    NSString *message = [NSString stringWithFormat:@"%@: {method: didFailWithError:, error: %@}", self.TAG, error.localizedDescription];
    NSLog(@"%@", message);
    Yodo1MasError *rewardError = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    [self callbackWithError:rewardError type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    self.rewardAd = nil;
    self.rewardModel = nil;
    [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
    [self nextReward];
    [self loadRewardAd];
}


/// 激励视频广告播放完成或发生错误
- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
     
}

- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
   
}

- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    if (verify) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

/// 激励视频广告点击
- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
   
}


@end
