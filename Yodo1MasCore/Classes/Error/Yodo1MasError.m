//
//  Yodo1MasError.m
//  AFNetworking
//
//  Created by ZhouYuzhen on 2020/12/16.
//

#import "Yodo1MasError.h"

@implementation Yodo1MasError

- (instancetype)initWitCode:(Yodo1MasErrorCode)code message:(NSString * _Nullable)message {
    self = [super initWithDomain:@"www.yodo1.com" code:code userInfo:@{NSLocalizedDescriptionKey: message != nil ? message : @"", NSLocalizedFailureReasonErrorKey: message != nil ? message : @""}];
    if (self) {
        
    }
    return self;
}

- (NSDictionary *)getJsonObject {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    json[@"code"] = @(self.code);
    json[@"message"] = self.userInfo[NSLocalizedDescriptionKey];
    return json;
}

@end
