//
//  Yodo1MasNetworkMediation.h
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasNetworkMediation : NSObject

@property (nonatomic, copy) NSString *mediation_name;
@property (nonatomic, assign) int priority;
@property (nonatomic, copy) NSString *ad_unit_id;

@end

NS_ASSUME_NONNULL_END
