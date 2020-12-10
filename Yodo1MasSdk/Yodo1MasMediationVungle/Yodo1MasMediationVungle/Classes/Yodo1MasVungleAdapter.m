//
//  Yodo1MasVungleAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasVungleAdapter.h"
#import <VungleSDK/VungleSDK.h>

@interface Yodo1MasVungleAdapter()

@end

@implementation Yodo1MasVungleAdapter

- (NSString *)advertCode {
    return @"Vungle";
}

- (NSString *)sdkVersion {
    return @"1.0.0";
}

- (NSString *)mediationVersion {
    return @"0.0.0.1-beta";
}

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail {
    [super initWithConfig:config successful:successful fail:fail];
    
    if (![self isInitSDK]) {
        NSError *error;
        BOOL initSdk = [[VungleSDK sharedSDK] startWithAppId:config.appId error:&error];
        if (initSdk) {
            if (successful != nil) {
                successful(self.advertCode);
            }
        } else {
            if (fail != nil) {
                fail(self.advertCode, error);
            }
        }
    }
    
}

- (BOOL)isInitSDK {
    return [[VungleSDK sharedSDK] isInitialized];
}

@end
