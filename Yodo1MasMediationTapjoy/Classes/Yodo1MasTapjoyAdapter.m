//
//  Yodo1MasTapjoyAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasTapjoyAdapter.h"
#import <Tapjoy/Tapjoy.h>

#define TAG @"[Yodo1MasTapjoyAdapter]"
#define PLACEMENT_NAME_VIDEO        @"reward_advert"
#define PLACEMENT_NAME_INTERSTITIAL @"interstitial_advert"

@interface Yodo1MasTapjoyAdapter()<TJPlacementDelegate>

@property (nonatomic, strong) TJPlacement *rewardAd;
@property (nonatomic, strong) TJPlacement *interstitialAd;

@end

@implementation Yodo1MasTapjoyAdapter

- (NSString *)advertCode {
    return @"Tapjoy";
}

- (NSString *)sdkVersion {
    return [Tapjoy getVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.2-beta";
}

-(void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail  {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapjoyConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapjoyConnectFail:) name:TJC_CONNECT_FAILED object:nil];
        
        if (config.appId != nil && config.appId.length > 0) {
            [Tapjoy connect:config.appId];
        } else {
            NSString *message = [NSString stringWithFormat:@"%@: {method:initWithConfig:, error: config.appId is null}",TAG];
            NSLog(message);
            if (fail != nil) {
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
                fail(self.advertCode, error);
            }
        }
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (void)onTapjoyConnectSuccess:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onTapjoyConnectSuccess:, init successful}", TAG];
    NSLog(message);
    
    [self updatePrivacy];
    [self loadRewardAd];
    [self loadInterstitialAd];
    [self loadBannerAd];
    if (self.initSuccessfulCallback != nil) {
        self.initSuccessfulCallback(self.advertCode);
    }
}

- (void)onTapjoyConnectFail:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onTapjoyConnectFail:, init failed, info: %@}", TAG, notification.userInfo];
    NSLog(message);
    if (self.initFailCallback != nil) {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:message];
        self.initFailCallback(self.advertCode, error);
    }
}

- (BOOL)isInitSDK {
    [super isInitSDK];
    return [Tapjoy isConnected];
}

- (void)updatePrivacy {
    [super updatePrivacy];
    TJPrivacyPolicy *policy = [TJPrivacyPolicy sharedInstance];
    if ([Yodo1Mas sharedInstance].isGDPRUserConsent) {
        [policy setUserConsent:@"1"];
        [policy setSubjectToGDPR:YES];
    } else {
        [policy setUserConsent:@"0"];
        [policy setSubjectToGDPR:NO];
    }
    [policy setBelowConsentAge:[Yodo1Mas sharedInstance].isCOPPAAgeRestricted];
    
    if ([Yodo1Mas sharedInstance].isCCPADoNotSell) {
        [policy setUSPrivacy:@"1-N-"];
    } else {
        [policy setUSPrivacy:@"1-Y-"];
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    [super isRewardAdLoaded];
    return _rewardAd != nil && [_rewardAd isContentAvailable];
}

- (void)loadRewardAd {
    [super loadRewardAd];
    if (![self isInitSDK]) return;
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd, loading reward ad...}", TAG];
    NSLog(message);
    _rewardAd = [TJPlacement placementWithName:PLACEMENT_NAME_VIDEO delegate:self];
    [_rewardAd requestContent];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showRewardAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasTapjoyAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd:, show reward ad...}", TAG];
            NSLog(message);
            [_rewardAd showContentWithViewController:controller];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    [super isInterstitialAdLoaded];
    return _interstitialAd != nil && [_interstitialAd isContentAvailable];
}

- (void)loadInterstitialAd {
    [super loadInterstitialAd];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd, loading interstitial ad...}", TAG];
    NSLog(message);
    
    _interstitialAd = [TJPlacement placementWithName:PLACEMENT_NAME_INTERSTITIAL delegate:self];
    [_interstitialAd requestContent];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAd:callback object:object];
    if ([self isCanShow:Yodo1MasAdTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasTapjoyAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:, show interstitial ad...}", TAG];
            NSLog(message);
            [_interstitialAd showContentWithViewController:controller];
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

#pragma mark - TJPlacementDelegate
- (void)requestDidSucceed:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@: {method: requestDidSucceed:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@: {method: requestDidFail:error:, placement: %@, error: %@}", TAG, placement.placementName, adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:message];
    if (placement == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeReward];
        [self loadRewardAdDelayed];
    } else if (placement == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdTypeInterstitial];
        [self loadInterstitialAdDelayed];
    }
}

- (void)contentIsReady:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@: {method: contentIsReady:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
}

- (void)contentDidAppear:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@: {method: contentDidAppear:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
    
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
    } else if (placement == _interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
    }
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@: {method: contentDidDisappear:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
    
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
        [self loadRewardAd];
    } else if (placement == _interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
        [self loadInterstitialAd];
    }
}

- (void)didClick:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@: {method: didClick:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
}

- (void)placement:(TJPlacement *)placement didRequestPurchase:(TJActionRequest*)request productId:(NSString *)productId {
    NSString *message = [NSString stringWithFormat:@"%@: {method: placement:didRequestPurchase:productId:, placement: %@, request: %@, productId: %@}", TAG, placement.placementName, request.requestId, productId];
    NSLog(message);
}

- (void)placement:(TJPlacement *)placement didRequestReward:(TJActionRequest*)request itemId:(NSString *)itemId quantity:(int)quantity {
    NSString *message = [NSString stringWithFormat:@"%@: {method: placement:didRequestPurchase:productId:, placement: %@, request: %@, itemId: %@, quantity: %@}", TAG, placement.placementName, request.requestId, itemId, @(quantity)];
    NSLog(message);
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
    }
}

@end
