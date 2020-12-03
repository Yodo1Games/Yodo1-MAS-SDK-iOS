//
//  Yodo1MasNetworkWaterfall.m
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1MasNetworkWaterfall.h"
#import "YYModel.h"

@implementation Yodo1MasNetworkWaterfall

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"ad_network_placements" : [Yodo1MasNetworkPlacement class]};
}

@end
