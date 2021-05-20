//
//  Yodo1LuckyWheelHelper.m
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1LuckyWheelHelper.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "Yodo1MasStorage.h"
#import "Yodo1Mas.h"
#import "Yodo1LuckyWheelViewController.h"

NSString* const kRewardGameParameterUrl     = @"https://tyche-api.yodo1.com/api/activity/";
NSString* const kYodo1OPCacheRewardGameKey  = @"yodo1OPCacheRewardGameKey";

NSString* const kYodo1MasSecret = @"7vJvQSZbcMTggaay2pD47l5l";

typedef enum {
    Yodo1LuckyWheelErrorCodeUnknown = -1,
    Yodo1LuckyErrorCodeConfigNetwork = -100000, //No WIFI/4G or Request Timeout
    Yodo1LuckyErrorCodeConfigException = -100501, //Data parsing failed
    Yodo1LuckyErrorCodeAppKeyIllegal = -400000, //Invalid AppKey or Wrong AppKey
} Yodo1LuckyWheelErrorCode;

@interface Yodo1LuckyWheelError : NSError
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict NS_UNAVAILABLE;

- (instancetype)initWitCode:(Yodo1LuckyWheelErrorCode)code
                    message:(NSString * _Nullable)message;

- (NSDictionary *)getJsonObject;

@end

@implementation Yodo1LuckyWheelError

- (instancetype)initWitCode:(Yodo1LuckyWheelErrorCode)code
                    message:(NSString * _Nullable)message {
    self = [super initWithDomain:@"www.yodo1.com" code:code
                        userInfo:@{NSLocalizedDescriptionKey: message != nil ? message : @"", NSLocalizedFailureReasonErrorKey: message != nil ? message : @""}];
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


@interface Yodo1LuckyWheelHelper() {
}

@property (nonatomic, weak) id<Yodo1MasLuckyWheelInitializeDelegate> luckyWheelInitializeDelegate;

@end

@implementation Yodo1LuckyWheelHelper

+ (Yodo1LuckyWheelHelper *)shared {
    static Yodo1LuckyWheelHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1LuckyWheelHelper alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)initWithAppKey:(NSString *)appKey
              delegate:(nonnull id<Yodo1MasLuckyWheelInitializeDelegate>)delegate {
    _appKey = appKey;
    self.luckyWheelInitializeDelegate = delegate;
    if (!appKey|| !appKey.length) {
        if (delegate && [delegate respondsToSelector:@selector(onFailure:)]) {
            NSError* error = [[Yodo1LuckyWheelError alloc] initWitCode:Yodo1LuckyErrorCodeAppKeyIllegal
                                                               message:@"Invalid AppKey or Wrong AppKey"];
            [delegate onFailure:error];
        }
        return;
    }
    [self fetchRewardGameConfig];
}


- (NSString *)nowTimeTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%f", [datenow timeIntervalSince1970]*1000];
    timeSp = [[timeSp componentsSeparatedByString:@"."]objectAtIndex:0];
    return timeSp;
}

- (NSString *)signMd5String:(NSString *)origString {
    const char *original_str = [origString UTF8String];
    unsigned char result[32];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

- (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error {
    if (obj) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSData* data = nil;
            @try {
                data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
            }
            @catch (NSException* exception)
            {
                *error = [NSError errorWithDomain:[exception description] code:0 userInfo:nil];
                return nil;
            }
            @finally
            {
            }
            
            if (data) {
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
    }
    return nil;
}

- (NSString *)language {
    NSString* lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray * langArrayWord = [lang componentsSeparatedByString:@"-"];
    NSString* langString = [langArrayWord objectAtIndex:0];
    if (langArrayWord.count >= 3) {
        langString = [NSString stringWithFormat:@"%@-%@",
                      [langArrayWord objectAtIndex:0],
                      [langArrayWord objectAtIndex:1]];
    }
    return langString;
}

- (void)show:(UIViewController *)viewcontroller
    delegate:(id<Yodo1MasLuckyWheelRewardDelegate>)delegate {
    [Yodo1LuckyWheelViewController show:viewcontroller delegate:delegate];
}

- (void)fetchRewardGameConfig {
    NSString * baseurl = kRewardGameParameterUrl;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseurl]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString* timestamp = [self nowTimeTimestamp];
    NSString* sign = [self signMd5String:[NSString stringWithFormat:@"%@%@%@%@",_appKey,[Yodo1MasStorage  keychainDeviceId],timestamp,kYodo1MasSecret]];
    NSDictionary* parameters = @{@"appkey":_appKey,
                                 @"device_id":[Yodo1MasStorage  keychainDeviceId],
                                 @"timestamp":timestamp,
                                 @"sign":sign,
                                 @"la":[self language]};
    
    __weak __typeof(self)weakSelf = self;
    [manager POST:@"config"
       parameters:parameters
          headers:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if DEBUG
        NSLog(@"respone - %@",responseObject);
#endif
        if ([responseObject[@"code"] intValue]) {return;}
        id data = responseObject[@"data"];
        BOOL activity = false;
        if ([data isKindOfClass:NSDictionary.class]) {
            activity = [data[@"activity_switch"] isEqualToString:@"on"];
            weakSelf.webUrl = data[@"web_url"];
        }
        weakSelf.activitySwitch = activity && weakSelf.webUrl.length;
        if (weakSelf.luckyWheelInitializeDelegate && [weakSelf.luckyWheelInitializeDelegate respondsToSelector:@selector(onSuccess:)]) {
            [weakSelf.luckyWheelInitializeDelegate onSuccess:weakSelf.activitySwitch];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
        if (weakSelf.luckyWheelInitializeDelegate && [weakSelf.luckyWheelInitializeDelegate respondsToSelector:@selector(onFailure:)]) {
            [weakSelf.luckyWheelInitializeDelegate onFailure:error];
        }
    }];
}


- (void)rewardGameReward:(NSDictionary *)para
                response:(void(^)(NSDictionary * rewardData))response {
    NSString * baseurl = kRewardGameParameterUrl;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseurl]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSMutableDictionary* parameters = para.mutableCopy;
    NSString* timestamp = [self nowTimeTimestamp];
    NSString* signStr = [NSString stringWithFormat:@"%@%@%@%@",_appKey,[Yodo1MasStorage  keychainDeviceId],timestamp,kYodo1MasSecret];
    NSString* sign = [self signMd5String:signStr];
    [parameters addEntriesFromDictionary:@{@"appkey":_appKey,
                                           @"device_id":[Yodo1MasStorage  keychainDeviceId],
                                           @"timestamp":timestamp,
                                           @"sign":sign,
                                           @"la":[self language]}];
    [manager POST:@"reward/collect"
       parameters:parameters
          headers:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if DEBUG
        NSLog(@"respone - %@",responseObject);
#endif
        NSDictionary * rewardData = responseObject[@"data"];
        if (rewardData && response) {response(rewardData);}
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
        if (response) {response(nil);}
    }];
}

@end
