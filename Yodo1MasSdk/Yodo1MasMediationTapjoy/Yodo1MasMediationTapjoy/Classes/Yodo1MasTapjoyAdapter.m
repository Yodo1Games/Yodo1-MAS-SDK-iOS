//
//  Yodo1MasTapjoyAdapter.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasTapjoyAdapter.h"
#import <Tapjoy/Tapjoy.h>

@interface Yodo1MasTapjoyAdapter()


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

- (BOOL)isInitSDK {
    return [Tapjoy isConnected];
}

- (void)onTapjoyConnectSuccess:(NSNotification *)notification {
    
}

- (void)onTapjoyConnectFail:(NSNotification *)notification {
    
}

@end
