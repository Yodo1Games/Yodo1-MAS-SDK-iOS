//
//  Yodo1MasUnityAdsAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasUnityAdsAdapter.h"
@import UnityAds;

@interface Yodo1MasUnityAdsAdapter()<UnityAdsInitializationDelegate>

@end

@implementation Yodo1MasUnityAdsAdapter

- (NSString *)advertCode {
    return @"UnityAds";
}

- (NSString *)sdkVersion {
    return [UnityAds getVersion];
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        [UnityAds initialize:config.appId initializationDelegate:self];
    } else {
        if (successful != nil) {
            successful(self.advertCode);
        }
    }
}

#pragma mark - UnityAdsInitializationDelegate
- (void)initializationComplete {
    if (self.initSuccessfulCallback != nil) {
        self.initSuccessfulCallback(self.advertCode);
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message {
    if (self.initFailCallback != nil) {
        self.initFailCallback(self.advertCode, [NSError errorWithDomain:@"" code:error userInfo:@{}]);
    }
}

- (BOOL)isInitSDK {
    return [UnityAds isInitialized];
}

@end
