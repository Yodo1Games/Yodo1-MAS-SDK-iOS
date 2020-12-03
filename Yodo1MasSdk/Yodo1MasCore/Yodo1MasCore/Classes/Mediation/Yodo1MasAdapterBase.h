//
//  Yodo1MasAdapterBase.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Yodo1MasAdapterInitSuccessful)(NSString *);
typedef void(^Yodo1MasAdapterInitFail)(NSString *, NSError *);

@interface Yodo1MasAdapterConfig : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appKey;

@end

@interface Yodo1MasAdapterBase : NSObject

- (NSString *)getAdvertCode;
- (NSString *)getSDKVersion;
- (NSString *)getMediationVersion;

- (void)initWithConfig:(Yodo1MasAdapterConfig *)config successful:(Yodo1MasAdapterInitSuccessful)successful fail:(Yodo1MasAdapterInitFail)fail;

@end

NS_ASSUME_NONNULL_END
