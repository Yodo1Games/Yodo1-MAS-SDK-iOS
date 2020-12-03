//
//  Yodo1MasNetworkPlacement.h
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasNetworkPlacement : NSObject

@property(nonatomic, copy) NSString *placement_id;
@property(nonatomic, copy) NSString *price_type;
@property(nonatomic, assign) NSInteger price;
@property(nonatomic, copy) NSString *extra_params;

@end

NS_ASSUME_NONNULL_END
