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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapjoyConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapjoyConnectFail:) name:TJC_CONNECT_FAILED object:nil];
        [Tapjoy connect:config.appKey];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

- (void)onTapjoyConnectSuccess:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"%@:{method: onTapjoyConnectSuccess:, init successful}", TAG];
    NSLog(message);
    
    [self updatePrivacy];
    [self loadRewardAdvert];
    [self loadInterstitialAdvert];
    [self loadBannerAdvert];
}

- (void)onTapjoyConnectFail:(NSNotification *)notification {
    NSString *message = [NSString stringWithFormat:@"%@:{method: onTapjoyConnectFail:, init failed}", TAG];
    NSLog(message);
}

- (BOOL)isInitSDK {
    return [Tapjoy isConnected];
}

- (void)updatePrivacy {
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
    return _rewardAd != nil && [_rewardAd isContentAvailable];
}

- (void)loadRewardAdvert {
    if (![self isInitSDK]) return;
    _rewardAd = [TJPlacement placementWithName:PLACEMENT_NAME_VIDEO delegate:self];
    [_rewardAd requestContent];
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showRewardAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeReward callback:callback]) {
        if (controller == nil) {
            controller = [Yodo1MasTapjoyAdapter getTopViewController];
        }
        if (controller != nil) {
            [_rewardAd showContentWithViewController:controller];
        }
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return _interstitialAd != nil && [_interstitialAd isContentAvailable];
}

- (void)loadInterstitialAdvert {
    if (![self isInitSDK]) return;
    _interstitialAd = [TJPlacement placementWithName:PLACEMENT_NAME_INTERSTITIAL delegate:self];
    [_interstitialAd requestContent];
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showInterstitialAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeInterstitial callback:callback]) {
        if (controller == nil) {
            controller = [Yodo1MasTapjoyAdapter getTopViewController];
        }
        if (controller != nil) {
            [_interstitialAd showContentWithViewController:controller];
        }
    }
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return NO;
}

- (void)loadBannerAdvert {
    [super loadBannerAdvert];
}

- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    [super showBannerAdvert:controller callback:callback];
    if ([self isCanShow:Yodo1MasAdvertTypeBanner callback:callback]) {
        
    }
}

#pragma mark - TJPlacementDelegate
- (void)requestDidSucceed:(TJPlacement *)placement {
    
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)adError {
    NSString *message = [NSString stringWithFormat:@"%@:{method: requestDidFail:error:, placement: %@, error: %@}", TAG, placement.placementName, adError];
    NSLog(message);
    
    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertLoadFail message:message];
    if (placement == _rewardAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeReward];
    } else if (placement == _interstitialAd) {
        [self callbackWithError:error type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)contentIsReady:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@:{method: contentIsReady:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
}

- (void)contentDidAppear:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@:{method: contentDidAppear:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
    
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeReward];
    } else if (placement == _interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeOpened type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@:{method: contentDidDisappear:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
    
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeReward];
    } else if (placement == _interstitialAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeClosed type:Yodo1MasAdvertTypeInterstitial];
    }
}

- (void)didClick:(TJPlacement *)placement {
    NSString *message = [NSString stringWithFormat:@"%@:{method: didClick:, placement: %@}", TAG, placement.placementName];
    NSLog(message);
}

- (void)placement:(TJPlacement *)placement didRequestPurchase:(TJActionRequest*)request productId:(NSString *)productId {
    NSString *message = [NSString stringWithFormat:@"%@:{method: placement:didRequestPurchase:productId:, placement: %@, request: %@, productId: %@}", TAG, placement.placementName, request.requestId, productId];
    NSLog(message);
}

- (void)placement:(TJPlacement *)placement didRequestReward:(TJActionRequest*)request itemId:(NSString *)itemId quantity:(int)quantity {
    NSString *message = [NSString stringWithFormat:@"%@:{method: placement:didRequestPurchase:productId:, placement: %@, request: %@, itemId: %@, quantity: %@}", TAG, placement.placementName, request.requestId, itemId, @(quantity)];
    NSLog(message);
    if (placement == _rewardAd) {
        [self callbackWithEvent:Yodo1MasAdvertEventCodeRewardEarned type:Yodo1MasAdvertTypeReward];
    }
}

@end
