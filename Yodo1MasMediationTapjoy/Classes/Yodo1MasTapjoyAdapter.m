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
    return @"0.0.0.1-beta";
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
                Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
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
    [self loadRewardAdvert];
    [self loadInterstitialAdvert];
    [self loadBannerAdvert];
    if (self.initSuccessfulCallback != nil) {
        self.initSuccessfulCallback(self.advertCode);
    }
}

- (void)onTapjoyConnectFail:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"%@: {method: onTapjoyConnectFail:, init failed, info: %@}", TAG, notification.userInfo];
    NSLog(message);
    if (self.initFailCallback != nil) {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:message];
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
- (BOOL)isRewardAdvertLoaded {
    [super isRewardAdvertLoaded];
    return _rewardAd != nil && [_rewardAd isContentAvailable];
}

- (void)loadRewardAdvert {
    [super loadRewardAdvert];
    if (![self isInitSDK]) return;
    
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAdvert, loading reward ad...}", TAG];
    NSLog(message);
    _rewardAd = [TJPlacement placementWithName:PLACEMENT_NAME_VIDEO delegate:self];
    [_rewardAd requestContent];
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback object:(NSDictionary *)object {
    [super showRewardAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        UIViewController *controller = [Yodo1MasTapjoyAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAdvert:, show reward ad...}", TAG];
            NSLog(message);
            [_rewardAd showContentWithViewController:controller];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    [super isInterstitialAdvertLoaded];
    return _interstitialAd != nil && [_interstitialAd isContentAvailable];
}

- (void)loadInterstitialAdvert {
    [super loadInterstitialAdvert];
    if (![self isInitSDK]) return;
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert, loading interstitial ad...}", TAG];
    NSLog(message);
    
    _interstitialAd = [TJPlacement placementWithName:PLACEMENT_NAME_INTERSTITIAL delegate:self];
    [_interstitialAd requestContent];
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback object:(NSDictionary *)object {
    [super showInterstitialAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        UIViewController *controller = [Yodo1MasTapjoyAdapter getTopViewController];
        if (controller != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:, show interstitial ad...}", TAG];
            NSLog(message);
            [_interstitialAd showContentWithViewController:controller];
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    [super isBannerAdvertLoaded];
    return NO;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback object:(NSDictionary *)object {
    [super showBannerAdvert:callback object:object];
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        
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
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    if (placement == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
        [self loadRewardAdvertDelayed];
    } else if (placement == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
        [self loadInterstitialAdvertDelayed];
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
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
    } else if (placement == _interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@: {method: contentDidDisappear:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
    
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
        [self loadRewardAdvert];
    } else if (placement == _interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
        [self loadInterstitialAdvert];
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
        [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
    }
}

@end
