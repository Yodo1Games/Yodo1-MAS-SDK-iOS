//
//  Yodo1MasAdapterBase.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdapterBase.h"

#define TAG @"[Yodo1MasAdapterBase]"

@implementation Yodo1MasAdapterConfig

@end

@implementation Yodo1MasAdId

- (instancetype)initWitId:(NSString *)adId object:(id)object {
    self = [super init];
    if (self) {
        _adId = adId;
        _object = object;
    }
    return self;
}

@end

@interface Yodo1MasAdapterBase()

@property (nonatomic, assign) NSInteger currentRewardAdIdIndex;
@property (nonatomic, assign) NSInteger currentInterstitialAdIdIndex;
@property (nonatomic, assign) NSInteger currentBannerAdIdIndex;

@end

@implementation Yodo1MasAdapterBase

- (NSString *)getAdvertCode {
    return nil;
}

- (NSString *)getSDKVersion {
    return nil;
}

- (NSString *)getMediationVersion {
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentRewardAdIdIndex = -1;
        _rewardAdIds = [NSMutableArray array];
        _currentInterstitialAdIdIndex = -1;
        _interstitialAdIds = [NSMutableArray array];
        _currentBannerAdIdIndex = -1;
        _bannerAdIds = [NSMutableArray array];
        _bannerState = Yodo1MasBannerStateNone;
    }
    return self;
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    _initSuccessfulCallback = successful;
    _initFailCallback = fail;
}

- (BOOL)isInitSDK {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isInitSDK}", TAG];
    NSLog(message);
    return NO;
}

- (void)updatePrivacy {
    NSString *message = [NSString stringWithFormat:@"%@: {method: updatePrivacy}", TAG];
    NSLog(message);
}

- (void)nextReward {
    if (_currentRewardAdIdIndex < 0) {
        _currentRewardAdIdIndex = 0;
    } else {
        _currentRewardAdIdIndex++;
    }
    if (_currentRewardAdIdIndex >= _rewardAdIds.count) {
        _currentRewardAdIdIndex = 0;
    }
}

- (Yodo1MasAdId *)getRewardAdId {
    if (_currentRewardAdIdIndex >= _rewardAdIds.count || _currentRewardAdIdIndex < 0) {
        _currentRewardAdIdIndex = 0;
    }
    return _rewardAdIds.count > _currentRewardAdIdIndex ? _rewardAdIds[_currentRewardAdIdIndex] : nil;
}

- (void)nextInterstitial {
    if (_currentInterstitialAdIdIndex < 0) {
        _currentInterstitialAdIdIndex = 0;
    } else {
        _currentInterstitialAdIdIndex++;
    }
    if (_currentInterstitialAdIdIndex >= _rewardAdIds.count) {
        _currentInterstitialAdIdIndex = 0;
    }
}

- (Yodo1MasAdId *)getInterstitialAdId {
    if (_currentInterstitialAdIdIndex >= _interstitialAdIds.count || _currentInterstitialAdIdIndex < 0) {
        _currentInterstitialAdIdIndex = 0;
    }
    return _interstitialAdIds.count > _currentInterstitialAdIdIndex ? _interstitialAdIds[_currentInterstitialAdIdIndex] : nil;
}

- (void)nextBanner {
    if (_currentBannerAdIdIndex < 0) {
        _currentBannerAdIdIndex = 0;
    } else {
        _currentBannerAdIdIndex++;
    }
    if (_currentBannerAdIdIndex >= _rewardAdIds.count) {
        _currentBannerAdIdIndex = 0;
    }
}

- (Yodo1MasAdId *)getBannerAdId {
    if (_currentBannerAdIdIndex >= _bannerAdIds.count || _currentBannerAdIdIndex < 0) {
        _currentBannerAdIdIndex = 0;
    }
    return _bannerAdIds.count > _currentBannerAdIdIndex ? _bannerAdIds[_currentBannerAdIdIndex] : nil;
}

- (BOOL)isAdLoaded:(Yodo1MasAdType)type {
    switch (type) {
        case Yodo1MasAdTypeReward: {
            return [self isRewardAdLoaded];
        }
        case Yodo1MasAdTypeInterstitial: {
            return [self isInterstitialAdLoaded];
        }
        case Yodo1MasAdTypeBanner: {
            return [self isBannerAdLoaded];
        }
    }
    return NO;
}

- (void)loadAd:(Yodo1MasAdType)type {
    switch (type) {
        case Yodo1MasAdTypeReward: {
            [self loadRewardAd];
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            [self loadInterstitialAd];
            break;
        }
        case Yodo1MasAdTypeBanner: {
            [self loadBannerAd];
            break;
        }
    }
}

- (void)loadAdDelayed:(Yodo1MasAdType)type {
    switch (type) {
        case Yodo1MasAdTypeReward: {
            [self loadRewardAdDelayed];
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            [self loadInterstitialAdDelayed];
            break;
        }
        case Yodo1MasAdTypeBanner: {
            [self loadBannerAdDelayed];
            break;
        }
    }
}

- (void)showAd:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    switch (type) {
        case Yodo1MasAdTypeReward: {
            [self showRewardAd:callback object:object];
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            [self showInterstitialAd:callback object:object];
            break;
        }
        case Yodo1MasAdTypeBanner: {
            [self showBannerAd:callback object:object];
            break;
        }
    }
}

- (BOOL)isCanShow:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback {
    if ([self isInitSDK]) {
        if ([self isAdLoaded:type]) {
            return YES;
        } else {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdNoLoaded message:@"ad has not been cached"];
            Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:type message:@"" error:error];
            if(callback != nil) callback(event);
            return NO;
        }
    } else {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:@"adapter has not been inited"];
        Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:type message:@"" error:error];
        if(callback != nil) callback(event);
        return NO;
    }
}

- (void)callbackWithEvent:(Yodo1MasAdEvent *)event {
    if (event == nil) {
        return;
    }
    NSString *message = [NSString stringWithFormat:@"%@: {method: callbackWtihEvent, event: %@}", TAG, [event getJsonObject]];
    NSLog(message);
    switch (event.type) {
        case Yodo1MasAdTypeReward: {
            if (self.rewardCallback != nil) {
                self.rewardCallback(event);
            }
            break;
        }
        case Yodo1MasAdTypeInterstitial: {
            if (self.interstitialCallback != nil) {
                self.interstitialCallback(event);
            }
            break;
        }
        case Yodo1MasAdTypeBanner: {
            if (self.bannerCallback != nil) {
                self.bannerCallback(event);
            }
            break;
        }
    }
}

- (void)callbackWithEvent:(Yodo1MasAdEventCode)code type:(Yodo1MasAdType)type {
    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:code type:type];
    [self callbackWithEvent:event];
}

- (void)callbackWithError:(Yodo1MasError *)error type:(Yodo1MasAdType)type {
    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:type error:error];
    [self callbackWithEvent:event];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isRewardAdLoaded}", TAG];
    NSLog(message);
    return NO;
}

- (void)loadRewardAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAd}", TAG];
    NSLog(message);
}

- (void)loadRewardAdDelayed {
    [self performSelector:@selector(loadRewardAd) withObject:nil afterDelay:DelayTime];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAd:object:}", TAG];
    NSLog(message);
    _rewardCallback = callback;
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isInterstitialAdLoaded}", TAG];
    NSLog(message);
    return NO;
}

- (void)loadInterstitialAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAd}", TAG];
    NSLog(message);
}

- (void)loadInterstitialAdDelayed {
    [self performSelector:@selector(loadInterstitialAd) withObject:nil afterDelay:DelayTime];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAd:object:}", TAG];
    NSLog(message);
    _interstitialCallback = callback;
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isBannerAdLoaded}", TAG];
    NSLog(message);
    return NO;
}

- (void)loadBannerAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadBannerAd}", TAG];
    NSLog(message);
}

- (void)loadBannerAdDelayed {
    [self performSelector:@selector(loadBannerAd) withObject:nil afterDelay:DelayTime];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    NSString *message = [NSString stringWithFormat:@"%@: {method: showBannerAd:object:}", TAG];
    NSLog(message);
    _bannerCallback = callback;
}

- (void)dismissBannerAd {
    NSString *message = [NSString stringWithFormat:@"%@: {method: dismissBannerAd}", TAG];
    NSLog(message);
}

#pragma mark - Method
+ (UIWindow *)getTopWindow {
    UIWindow *rootWindow;
    NSArray<UIWindow *> *windows;
    
    if (windows == nil) {
        UIApplication *app = [UIApplication sharedApplication];
        if (@available(iOS 13.0, *)) {
            if (app.supportsMultipleScenes) {
                for (UIScene *scene in app.connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                        windows = ((UIWindowScene *)scene).windows;
                        break;
                    }
                }
            }
        }
        if (windows == nil) {
            windows = app.windows;
        }
    }
    
    if (windows != nil) {
        if (rootWindow == nil) {
            for (UIWindow *window in windows) {
                if (window.isKeyWindow) {
                    rootWindow = window;
                    break;
                }
            }
        }
        
        if (rootWindow == nil) {
            for (UIWindow *window in windows) {
                if (window.windowLevel == 0) {
                    rootWindow = window;
                    break;
                }
            }
        }
    }
    return rootWindow;
}

+ (UIViewController *)getTopViewController {
    UIWindow *window = [self getTopWindow];
    if (window) {
        return [self getTopViewController:window.rootViewController];
    }
    return nil;
}

+ (UIViewController *)getTopViewController: (UIViewController *)controller {
    if (controller.presentedViewController) {
        return [self getTopViewController:controller.presentedViewController];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)controller;
        return [self getTopViewController:tabBarController.selectedViewController];
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)controller;
        return [self getTopViewController:navController.visibleViewController];
    } else {
        return controller;
    }
}

@end
