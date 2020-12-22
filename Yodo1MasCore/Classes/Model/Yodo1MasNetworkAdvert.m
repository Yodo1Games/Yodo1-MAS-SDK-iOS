//
//  Yodo1MasNetworkAdvert.m
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasNetworkAdvert.h"

@implementation Yodo1MasNetworkAdvert

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"mediation_list" : [Yodo1MasNetworkMediation class],
             @"fallback_waterfall" : [Yodo1MasNetworkWaterfall class]};
}

@end
