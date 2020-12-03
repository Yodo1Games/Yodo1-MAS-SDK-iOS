//
//  Yodo1MasNetworkAdvert.h
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1MasNetworkWaterfall.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasNetworkAdvert : NSObject

@property(nonatomic, copy) NSString *mediation;
@property(nonatomic, copy) NSString *mediation_unit_id;
@property(nonatomic, assign) BOOL mediation_active;
@property(nonatomic, strong) NSArray<Yodo1MasNetworkWaterfall *> *fallback_waterfall;

@end

NS_ASSUME_NONNULL_END
