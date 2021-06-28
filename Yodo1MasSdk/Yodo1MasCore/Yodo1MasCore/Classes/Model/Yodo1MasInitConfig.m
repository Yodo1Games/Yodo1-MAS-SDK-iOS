//
//  Yodo1MasInitConfig.m
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasInitConfig.h"

@implementation Yodo1MasInitConfig

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"mediation_list" : [Yodo1MasInitMediationInfo class],
             @"ad_network_list" : [Yodo1MasInitNetworkInfo class]};
}

@end
