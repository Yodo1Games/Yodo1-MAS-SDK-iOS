//
//  Yodo1MasAdapterBase.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasAdapterBase.h"

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
    return NO;
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

- (void)showAdvert:(UIViewController *)controller type:(Yodo1MasAdvertType)type callback:(Yodo1MasAdvertCallback)callback {
    switch (type) {
        case Yodo1MasAdvertTypeReward: {
            [self showRewardAdvert:controller callback:callback];
            break;
        }
        case Yodo1MasAdvertTypeInterstitial: {
            [self showInterstitialAdvert:controller callback:callback];
            break;
        }
        case Yodo1MasAdvertTypeBanner: {
            [self showBannerAdvert:controller callback:callback];
            break;
        }
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return NO;
}

- (void)loadRewardAdvert {
    
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    _rewardCallback = callback;
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return NO;
}

- (void)loadInterstitialAdvert {
    
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    _interstitialCallback = callback;
}


#pragma mark - 插屏广告
- (BOOL)isBannerAdvertLoaded {
    return NO;
}

- (void)loadBannerAdvert {
    
}

- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    _bannerCallback = callback;
}

- (void)dismissBannerAdvert {
    
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
