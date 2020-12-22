//
//  Yodo1MasAdvertEvent.h
//  AFNetworking
//
//  Created by ZhouYuzhen on 2020/12/16.
//

#import <Foundation/Foundation.h>
#import "Yodo1MasError.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasAdvertEvent : NSObject

@property (nonatomic, assign, readonly) Yodo1MasAdvertEventCode code;
@property (nonatomic, copy, readonly) NSString * _Nullable message;
@property (nonatomic, assign, readonly) Yodo1MasAdvertType type;
@property (nonatomic, strong, readonly) Yodo1MasError * _Nullable error;

- (instancetype)initWithCode:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type;
- (instancetype)initWithCode:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type error:(Yodo1MasError * _Nullable)error;
- (instancetype)initWithCode:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type message:(NSString * _Nullable)message error:(Yodo1MasError * _Nullable)error;

- (NSDictionary *)getJsonObject;

@end

NS_ASSUME_NONNULL_END
