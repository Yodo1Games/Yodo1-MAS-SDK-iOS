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
    
}

- (BOOL)isInitSDK {
    return false;
}

- (BOOL)isVideoAdvertLoaded {
    return false;
}

- (void)loadVideoAdvert {
    
}

- (void)showVideoAdvert {
    
}



@end
