//
//  Yodo1MasAdColonyAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdColonyAdapter.h"
#import <AdColony/AdColony.h>

#define BANNER_TAG 10011

@interface Yodo1MasAdColonyAdapter()<AdColonyInterstitialDelegate> {
    BOOL isRewardAdReady;
    BOOL isInterstitialAdReady;
    __block BOOL sdkInit;
    __block BOOL isCompleted;
}

@property (nonatomic, strong) AdColonyInterstitial *interstitialAd;
@property (nonatomic, strong) AdColonyInterstitial *rewardAd;

@end

@implementation Yodo1MasAdColonyAdapter

- (NSString *)advertCode {
    return @"adcolony";
}

- (NSString *)sdkVersion {
    return AdColony.getSDKVersion;
}

- (NSString *)mediationVersion {
    return @"4.0.2.1";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        AdColonyAppOptions *options = [AdColonyAppOptions new];
        if ([Yodo1Mas sharedInstance].isGDPRUserConsent) {
            [options setPrivacyConsentString:@"1" forType:ADC_GDPR];
            [options setPrivacyFrameworkOfType:ADC_GDPR isRequired:NO];
        }else{
            [options setPrivacyConsentString:@"0" forType:ADC_GDPR];
            [options setPrivacyFrameworkOfType:ADC_GDPR isRequired:YES];
        }
        
        if ([Yodo1Mas sharedInstance].isCCPADoNotSell) {
            [options setPrivacyConsentString:@"0" forType:ADC_CCPA];
            [options setPrivacyFrameworkOfType:ADC_CCPA isRequired:YES];
        } else {
            [options setPrivacyConsentString:@"1" forType:ADC_CCPA];//出售
            [options setPrivacyFrameworkOfType:ADC_CCPA isRequired:NO];
        }
        
        [options setPrivacyFrameworkOfType:ADC_COPPA isRequired:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
        
        Yodo1MasAdId *rewardAdId = [self getRewardAdId];
        Yodo1MasAdId *intersAdId = [self getRewardAdId];
        [AdColony configureWithAppID:config.appId
                             zoneIDs:@[rewardAdId.adId,intersAdId.adId]
                             options:options
                          completion:^(NSArray<AdColonyZone *> * zones) {
            for (AdColonyZone* zone in zones) {
                if (zone.rewarded) {
                    zone.reward = ^(BOOL success, NSString *name, int amount) {
                        self->isCompleted = success;
                    };
                    break;
                }
            }
            self->sdkInit = YES;
        }];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return sdkInit;
}

- (void)updatePrivacy {
    [super updatePrivacy];
}


#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return isRewardAdReady;
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    isRewardAdReady = NO;
    Yodo1MasAdId *adId = [self getRewardAdId];
    [AdColony requestInterstitialInZone:adId.adId options:nil andDelegate:self];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasAdColonyAdapter getTopViewController];
        if (controller != nil) {
            NSLog(@"%@:{method: showRewardAd, show reward ad...}", self.TAG);
            [self.rewardAd showWithPresentingViewController:controller];
        }
    }
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return isInterstitialAdReady;
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    Yodo1MasAdId *adId = [self getInterstitialAdId];
    [AdColony requestInterstitialInZone:adId.adId options:nil andDelegate:self];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasAdColonyAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method:showInterstitialAd:, show interstitial ad...}", self.TAG];
            NSLog(@"%@", message);
            [self.interstitialAd showWithPresentingViewController:controller];
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
        
        UIViewController *controller = [Yodo1MasAdColonyAdapter getTopViewController];
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

#pragma mark- AdColonyInterstitialDelegate

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    if ([self.rewardAd.zoneID isEqualToString:error.zoneId]) {
        isRewardAdReady = NO;
        NSString *message = [NSString stringWithFormat:@"%@: {method: adColonyInterstitialDidFailToLoad:, error: %@}", self.TAG, error.localizedDescription];
        NSLog(@"%@", message);
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAd];
    }else if ([self.interstitialAd.zoneID isEqualToString:error.zoneId]){
        isInterstitialAdReady = NO;
        NSString *message = [NSString stringWithFormat:@"%@: {method: adColonyInterstitialDidFailToLoad:, error: %@}", self.TAG, error.localizedDescription];
        NSLog(@"%@", message);
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self nextInterstitial];
        [self loadInterstitialAd];
    }
}

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    
    if ([interstitial.zoneID isEqualToString:[self getRewardAdId].adId]) {
        self.rewardAd = interstitial;
        isRewardAdReady = YES;
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeReward];
    }else if ([interstitial.zoneID isEqualToString:[self getInterstitialAdId].adId]){
        self.interstitialAd = interstitial;
        isInterstitialAdReady = YES;
        [self callbackWithAdLoadSuccess:Yodo1MasAdTypeInterstitial];
    }
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial *)interstitial {
    if ([interstitial.zoneID isEqualToString:[self getRewardAdId].adId]) {
        self.interstitialAd = nil;
        isInterstitialAdReady = NO;
    }else if ([interstitial.zoneID isEqualToString:[self getInterstitialAdId].adId]){
        self.interstitialAd = nil;
        isInterstitialAdReady = NO;
    }
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial * _Nonnull)interstitial {
    if ([interstitial.zoneID isEqualToString:[self getRewardAdId].adId]) {
        
        
    }else if ([interstitial.zoneID isEqualToString:[self getInterstitialAdId].adId]){
        
    }
}


- (void)adColonyInterstitialDidClose:(AdColonyInterstitial *)interstitial {
    
    if ([interstitial.zoneID isEqualToString:[self getRewardAdId].adId]) {
        if (isCompleted) {
            [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
            isCompleted = NO;
        }
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
        [self nextReward];
        [self loadRewardAd];
    }else if ([interstitial.zoneID isEqualToString:[self getInterstitialAdId].adId]){
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
        [self nextReward];
        [self loadInterstitialAd];
    }
    
}


@end
