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

- (BOOL)isAdvertLoaded:(Yodo1MasAdvertType)type {
    switch (type) {
        case Yodo1MasAdvertTypeReward: {
            return [self isRewardAdvertLoaded];
        }
        case Yodo1MasAdvertTypeInterstitial: {
            return [self isInterstitialAdvertLoaded];
        }
        case Yodo1MasAdvertTypeBanner: {
            return [self isBannerAdvertLoaded];
        }
    }
    return NO;
}

- (void)loadAdvert:(Yodo1MasAdvertType)type {
    switch (type) {
        case Yodo1MasAdvertTypeReward: {
            [self loadRewardAdvert];
            break;
        }
        case Yodo1MasAdvertTypeInterstitial: {
            [self loadInterstitialAdvert];
            break;
        }
        case Yodo1MasAdvertTypeBanner: {
            [self loadBannerAdvert];
            break;
        }
    }
}

- (void)loadAdvertDelayed:(Yodo1MasAdvertType)type {
    switch (type) {
        case Yodo1MasAdvertTypeReward: {
            [self loadRewardAdvertDelayed];
            break;
        }
        case Yodo1MasAdvertTypeInterstitial: {
            [self loadInterstitialAdvertDelayed];
            break;
        }
        case Yodo1MasAdvertTypeBanner: {
            [self loadBannerAdvertDelayed];
            break;
        }
    }
}

- (void)showAdvert:(Yodo1MasAdvertType)type callback:(Yodo1MasAdvertCallback)callback {
    switch (type) {
        case Yodo1MasAdvertTypeReward: {
            [self showRewardAdvert:callback];
            break;
        }
        case Yodo1MasAdvertTypeInterstitial: {
            [self showInterstitialAdvert:callback];
            break;
        }
        case Yodo1MasAdvertTypeBanner: {
            [self showBannerAdvert:callback];
            break;
        }
    }
}

- (BOOL)isCanShow:(Yodo1MasAdvertType)type callback:(Yodo1MasAdvertCallback)callback {
    if ([self isInitSDK]) {
        if ([self isAdvertLoaded:type]) {
            return YES;
        } else {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertNoLoaded message:@"ad config is null"];
            Yodo1MasAdvertEvent *event = [[Yodo1MasAdvertEvent alloc] initWithCode:Yodo1MasAdvertEventCodeError type:type message:@"" error:error];
            callback(event);
            return NO;
        }
    } else {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertUninitialized message:@"ad config is null"];
        Yodo1MasAdvertEvent *event = [[Yodo1MasAdvertEvent alloc] initWithCode:Yodo1MasAdvertEventCodeError type:type message:@"" error:error];
        callback(event);
        return NO;
    }
}

- (void)callbackWtihEvent:(Yodo1MasAdvertEvent *)event {
    if (event == nil) {
        return;
    }
    NSString *message = [NSString stringWithFormat:@"%@: {method: callbackWtihEvent, event: %@}", TAG, [event getJsonObject]];
    NSLog(message);
    switch (event.type) {
        case Yodo1MasAdvertTypeReward: {
            if (self.rewardCallback != nil) {
                self.rewardCallback(event);
            }
            break;
        }
        case Yodo1MasAdvertTypeInterstitial: {
            if (self.interstitialCallback != nil) {
                self.interstitialCallback(event);
            }
            break;
        }
        case Yodo1MasAdvertTypeBanner: {
            if (self.bannerCallback != nil) {
                self.bannerCallback(event);
            }
            break;
        }
    }
}

- (void)callbackWithEvent:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type {
    Yodo1MasAdvertEvent *event = [[Yodo1MasAdvertEvent alloc] initWithCode:code type:type];
    [self callbackWtihEvent:event];
}

- (void)callbackWithError:(Yodo1MasError *)error type:(Yodo1MasAdvertType)type {
    Yodo1MasAdvertEvent *event = [[Yodo1MasAdvertEvent alloc] initWithCode:Yodo1MasAdvertEventCodeError type:type error:error];
    [self callbackWtihEvent:event];
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isRewardAdvertLoaded}", TAG];
    NSLog(message);
    return NO;
}

- (void)loadRewardAdvert {
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadRewardAdvert}", TAG];
    NSLog(message);
}

- (void)loadRewardAdvertDelayed {
    [self performSelector:@selector(loadRewardAdvert) withObject:nil afterDelay:DelayTime];
}

- (void)showRewardAdvert:(Yodo1MasAdvertCallback)callback {
    NSString *message = [NSString stringWithFormat:@"%@: {method: showRewardAdvert:}", TAG];
    NSLog(message);
    _rewardCallback = callback;
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isInterstitialAdvertLoaded}", TAG];
    NSLog(message);
    return NO;
}

- (void)loadInterstitialAdvert {
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadInterstitialAdvert}", TAG];
    NSLog(message);
}

- (void)loadInterstitialAdvertDelayed {
    [self performSelector:@selector(loadInterstitialAdvert) withObject:nil afterDelay:DelayTime];
}

- (void)showInterstitialAdvert:(Yodo1MasAdvertCallback)callback {
    NSString *message = [NSString stringWithFormat:@"%@: {method: showInterstitialAdvert:}", TAG];
    NSLog(message);
    _interstitialCallback = callback;
}


#pragma mark - 插屏广告
- (BOOL)isBannerAdvertLoaded {
    NSString *message = [NSString stringWithFormat:@"%@: {method: isBannerAdvertLoaded}", TAG];
    NSLog(message);
    return NO;
}

- (void)loadBannerAdvert {
    NSString *message = [NSString stringWithFormat:@"%@: {method: loadBannerAdvert}", TAG];
    NSLog(message);
}

- (void)loadBannerAdvertDelayed {
    [self performSelector:@selector(loadBannerAdvert) withObject:nil afterDelay:DelayTime];
}

- (void)showBannerAdvert:(Yodo1MasAdvertCallback)callback {
    NSString *message = [NSString stringWithFormat:@"%@: {method: showBannerAdvert:}", TAG];
    NSLog(message);
    _bannerCallback = callback;
}

- (void)dismissBannerAdvert {
    NSString *message = [NSString stringWithFormat:@"%@: {method: dismissBannerAdvert}", TAG];
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
