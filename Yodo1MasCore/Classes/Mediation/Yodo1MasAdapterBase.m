//
//  Yodo1MasAdapterBase.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdapterBase.h"
#import <Yodo1SaAnalyticsSDK/Yodo1SaManager.h>
//#import "Yodo1SaManager.h"

@implementation Yodo1MasAdapterConfig

@end

@implementation Yodo1MasAdId

- (instancetype)initWitId:(NSString *)adId object:(id __nullable)object {
    self = [super init];
    if (self) {
        _adId = adId ? : @"";
        _object = object;
    }
    return self;
}

@end

@interface Yodo1MasAdapterBase()

@property (nonatomic, assign) NSInteger currentRewardAdIdIndex;
@property (nonatomic, assign) NSInteger currentInterstitialAdIdIndex;
@property (nonatomic, assign) NSInteger currentBannerAdIdIndex;

@property (nonatomic, assign) BOOL isReward;

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

- (NSString *)TAG {
    if (_TAG == nil) {
        _TAG = [NSString stringWithFormat:@"[%@]", NSStringFromClass([self class])];
    }
    return _TAG;
}

- (CGSize)adSize {
    BOOL isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    return isPad ? BANNER_SIZE_728_90 : BANNER_SIZE_320_50;
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
    NSLog(@"%@: {method: isInitSDK}", self.TAG);
    return NO;
}

- (void)updatePrivacy {
    NSLog(@"%@: {method: updatePrivacy}", self.TAG);
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
            self.isReward = NO;
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
    self.placement = object[kArgumentPlacement];
}

- (BOOL)isCanShow:(Yodo1MasAdType)type callback:(Yodo1MasAdCallback)callback {
    if ([self isInitSDK]) {
        if ([self isAdLoaded:type]) {
            return YES;
        } else {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdNoLoaded message:@"Ad not avaliable,no cache"];
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
    NSLog(@"%@: {method: callbackWtihEvent, event: %@}", self.TAG, [event getJsonObject]);
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
    if (event.code == Yodo1MasAdEventCodeError) {
        if (event.error.code == Yodo1MasErrorCodeAdLoadFail) {
            [self dataAnalyticsRequest:event.type success:NO];
        }
    }else{
        [self dataAnalyticsImpression:event];
    }
}

- (void)dataAnalyticsImpression:(Yodo1MasAdEvent *)event {
    switch (event.code) {
        case Yodo1MasAdEventCodeOpened: {
            ///Banner 没有关闭事件，在展示时触发上传事件
            if (event.type == Yodo1MasAdTypeBanner) {
                [self trackEventImpression:event success:YES];
            }
        } break;
        case Yodo1MasAdEventCodeClosed: {
            [self trackEventImpression:event success:YES];
        } break;
        case Yodo1MasAdEventCodeRewardEarned:{
            self.isReward = YES;
        } break;
        case Yodo1MasAdEventCodeError: {
            [self trackEventImpression:event success:NO];
        } break;
        default: break;
    }
}

- (void)dataAnalyticsRequest:(Yodo1MasAdType)type success:(BOOL)suc {
    NSMutableDictionary * dic = @{@"adType":[self type2string:type],
                                  @"adResult":suc ? @"success" : @"fail",
                                  @"adNetwork":self.advertCode ? : @"",
                                  @"adNetworkVersion":self.sdkVersion ? : @""}.mutableCopy;;
    [Yodo1SaManager track:@"adRequest" properties:dic];
}

- (void)trackEventImpression:(Yodo1MasAdEvent *)event success:(BOOL)suc {
    NSMutableDictionary * dic = @{@"adType":[self type2string:event.type],
                                  @"adResult":suc ? @"success" : @"fail",
                                  @"adNetwork":self.advertCode ? : @"",
                                  @"adPlacement":self.placement ? : [self defaultPlacement:event.type],
                                  @"adNetworkVersion":self.sdkVersion ? : @""}.mutableCopy;;
    if (suc) {
        if (event.type != Yodo1MasAdTypeBanner) {
            dic[@"adClose"] = @(YES);
        }
        if (event.type == Yodo1MasAdTypeReward) {
            dic[@"adComplete"] = @(self.isReward);
        }
    }
    [Yodo1SaManager track:@"adImpression" properties:dic];
}

- (NSString *)type2string:(Yodo1MasAdType)type {
    switch (type) {
        case Yodo1MasAdTypeBanner:          return @"bannerAd";    
        case Yodo1MasAdTypeInterstitial:    return @"interstitialAd";
        case Yodo1MasAdTypeReward:          return @"videoAd";
        default:                            return @"";
    }
}

- (NSString *)defaultPlacement:(Yodo1MasAdType)type {
    switch (type) {
        case Yodo1MasAdTypeBanner:          return @"defaultBanner";
        case Yodo1MasAdTypeInterstitial:    return @"defaultINTER";
        case Yodo1MasAdTypeReward:          return @"defaultRV";
        default:                            return @"";
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

- (void)callbackWithAdLoadSuccess:(Yodo1MasAdType)type {
    [self dataAnalyticsRequest:type success:YES];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    NSLog(@"%@: {method: isRewardAdLoaded}", self.TAG);
    return NO;
}

- (void)loadRewardAd {
    NSLog(@"%@: {method: loadRewardAd}", self.TAG);
}

- (void)loadRewardAdDelayed {
    [self performSelector:@selector(loadRewardAd) withObject:nil afterDelay:DelayTime];
}

- (void)showRewardAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    NSLog(@"%@: {method: showRewardAd:object:}", self.TAG);
    _rewardCallback = callback;
}

- (void)dismissRewardAd {
    
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    NSLog(@"%@: {method: isInterstitialAdLoaded}", self.TAG);
    return NO;
}

- (void)loadInterstitialAd {
    NSLog(@"%@: {method: loadInterstitialAd}", self.TAG);
}

- (void)loadInterstitialAdDelayed {
    [self performSelector:@selector(loadInterstitialAd) withObject:nil afterDelay:DelayTime];
}

- (void)showInterstitialAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    NSLog(@"%@: {method: showInterstitialAd:object:}", self.TAG);
    _interstitialCallback = callback;
}

- (void)dismissInterstitialAd {
    
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdLoaded {
    NSLog(@"%@: {method: isBannerAdLoaded}", self.TAG);
    return NO;
}

- (void)loadBannerAd {
    NSLog(@"%@: {method: loadBannerAd}", self.TAG);
}

- (void)loadBannerAdDelayed {
    [self performSelector:@selector(loadBannerAd) withObject:nil afterDelay:DelayTime];
}

- (void)showBannerAd:(Yodo1MasAdCallback)callback object:(NSDictionary *)object {
    NSLog(@"%@: {method: showBannerAd:object:}", self.TAG);
    _bannerCallback = callback;
}

- (void)dismissBannerAd {
    NSLog(@"%@: {method: dismissBannerAd}", self.TAG);
    [self dismissBannerAdWithDestroy:NO];
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    NSLog(@"%@: {method: dismissBannerAdWithDestroy:}, destroy: %@", self.TAG, @(destroy));
}

#pragma mark - Method
+ (UIWindow * _Nullable)getTopWindow {
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

+ (UIViewController * _Nullable)getTopViewController {
    UIWindow *window = [self getTopWindow];
    if (window) {
        return [self getTopViewController:window.rootViewController];
    }
    return nil;
}

+ (UIViewController * _Nullable)getTopViewController: (UIViewController *)controller {
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
