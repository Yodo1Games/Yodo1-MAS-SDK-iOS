//
//  Yodo1MasAdvertEvent.m
//  AFNetworking
//
//  Created by ZhouYuzhen on 2020/12/16.
//

#import "Yodo1MasAdvertEvent.h"

@interface Yodo1MasAdvertEvent()

@end

@implementation Yodo1MasAdvertEvent

- (instancetype)initWithCode:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type {
    self = [super init];
    if (self) {
        if (code == Yodo1MasAdvertEventCodeError) {
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:@"code cannot be Yodo1MasAdvertEventCodeError(-1)" userInfo:nil];
        }
        _code = code;
        _type = type;
        _message = nil;
        _error = nil;
    }
    return self;
}

- (instancetype)initWithCode:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type error:(Yodo1MasError * _Nullable)error {
    self = [super init];
    if (self) {
        if (code == Yodo1MasAdvertEventCodeError && error == nil) {
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:@"error cannot be null" userInfo:nil];
        }
        _code = code;
        _type = type;
        _message = nil;
        _error = error;
    }
    return self;
}

- (instancetype)initWithCode:(Yodo1MasAdvertEventCode)code type:(Yodo1MasAdvertType)type message:(NSString * _Nullable)message error:(Yodo1MasError * _Nullable)error {
    self = [super init];
    if (self) {
        if (code == Yodo1MasAdvertEventCodeError && error == nil) {
            @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:@"error cannot be null" userInfo:nil];
        }
        _code = code;
        _type = type;
        _message = message;
        _error = error;
    }
    return self;
}

- (NSDictionary *)getJsonObject {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    json[@"type"] = @(_type);
    json[@"code"] = @(_code);
    json[@"message"] = _message != nil ? _message : @"";
    if (_error != nil) {
        json[@"error"] = [_error getJsonObject];
    }
    return json;
}

@end
