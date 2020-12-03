//
//  Yodo1Mas.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1Mas.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "Yodo1MasResponse.h"
#import "Yodo1MasInitData.h"
#import "Yodo1MasAdapterBase.h"

@interface Yodo1Mas()

@property (nonatomic, strong) Yodo1MasInitConfig *masInitConfig;
@property (nonatomic, strong) Yodo1MasNetworkConfig *masNetworkConfig;
@property (nonatomic, strong) NSMutableDictionary *mediations;

@end

@implementation Yodo1Mas

+ (Yodo1Mas *)sharedInstance {
    static Yodo1Mas *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1Mas alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mediations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
    
    __weak __typeof(self)weakSelf = self;
    NSString *country = [NSLocale currentLocale].countryCode;
    NSString *url = [NSString stringWithFormat:@"http://massdk.cb64eaf4841914d918c93a30369d6bbc6.cn-beijing.alicontainer.com/init/%@", appId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:@{@"country": country} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Yodo1MasResponse *res = [Yodo1MasResponse yy_modelWithJSON:responseObject];
        if (res != nil && res.data != nil) {
            Yodo1MasInitData *data = [Yodo1MasInitData yy_modelWithJSON:res.data];
            weakSelf.masInitConfig = data.mas_init_config;
            weakSelf.masNetworkConfig = data.ad_network_config;
            if (data.mas_init_config && data.ad_network_config) {
                [weakSelf doInit:data.mas_init_config];
            } else {
                if (fail) {
                    fail([NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : @"获取配置失败"}]);
                }
            }
        } else {
            if (fail) {
                fail([NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : @"获取配置失败"}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail) {
            fail(error);
        }
    }];
}

- (void)doInit:(Yodo1MasInitConfig *)config {
    NSDictionary *mediations = @{
        @"AdMob" : @"Yodo1MasAdMobMaxAdapter",
        @"AppLovin" : @"Yodo1MasAppLovinMaxAdapter",
        @"IronSource" : @"Yodo1MasIronSourceMaxAdapter"
    };
    
    NSDictionary *networks = @{
        @"AdMob" : @"Yodo1MasAdMobAdapter",
        @"AppLovin" : @"Yodo1MasAppLovinAdapter",
        @"Facebook" : @"Yodo1MasFacebookAdapter",
        @"InMobi" : @"Yodo1MasInMobiAdapter",
        @"IronSource" : @"Yodo1MasIronSourceAdapter",
        @"Tapjoy" : @"Yodo1MasTapjoyAdapter",
        @"UnityAds" : @"Yodo1MasUnityAdsAdapter",
        @"Vungle" : @"Yodo1MasVungleAdapter"
    };
    
    if (config.mediation_list != nil && config.mediation_list.count > 0) {
        for (Yodo1MasInitMediationInfo *info in config.mediation_list) {
            NSString *key = info.name;
            NSString *value = mediations[key];
            [self doInitAdapter:key value:value appId:info.app_id appKey:info.app_key];
        }
    }
    
    if (config.ad_network_list != nil && config.ad_network_list.count > 0) {
        for (Yodo1MasInitNetworkInfo *info in config.ad_network_list) {
            NSString *key = info.ad_network_name;
            NSString *value = networks[key];
            [self doInitAdapter:key value:value appId:info.ad_network_app_id appKey:info.ad_network_app_key];
        }
    }
    
    [self loadRewardAdvert];
    [self loadInterstitialAdvert];
    [self loadBannerAdvert];
}

- (void)doInitAdapter:(NSString *)key value:(NSString *)value appId:(NSString *)appId appKey:(NSString *)appKey {
    if (value && value.length > 0) {
        Class c = NSClassFromString(value);
        NSObject *o = c != nil ? [[c alloc] init] : nil;
        if (o != nil && [o isKindOfClass:[Yodo1MasAdapterBase class]]) {
            
            __weak __typeof(self)weakSelf = self;
            
            Yodo1MasAdapterConfig *config = [[Yodo1MasAdapterConfig alloc] init];
            config.name = key;
            config.appId = appId;
            config.appKey = appKey;
            __weak Yodo1MasAdapterBase *adapter = (Yodo1MasAdapterBase *)o;
            [adapter initWithConfig:config successful:^(NSString *advertCode) {
                weakSelf.mediations[appId] = adapter;
                NSLog(@"Mediation初始化成功 - %@:%@", key, value);
            } fail:^(NSString *advertCode, NSError *error) {
                NSLog(@"Mediation初始化成功 - %@:%@, %@", key, value, error.description);
            }];
        } else {
            if (o == nil) {
                NSLog(@"未找到指定Mediation - %@", value);
            } else {
                NSLog(@"Mediation未继承Yodo1MasAdapterBase");
            }
        }
    } else {
        NSLog(@"未找到指定Mediation - %@", value);
    }
}

- (BOOL)isRewardAdvertLoaded {
    return NO;
}

- (void)loadRewardAdvert {
    
}

- (void)showRewardAdvert:(id<Yodo1MasAdvertRewardDelegate>)delegate {
    
}

- (BOOL)isInterstitialAdvertLoaded {
    return NO;
}

- (void)loadInterstitialAdvert {
    
}

- (void)showInterstitialAdvert:(id<Yodo1MasAdvertInterstitialDelegate>)delegate {
    
}

- (BOOL)isBannerAdvertLoaded {
    return NO;
}

- (void)loadBannerAdvert {
    
}

- (void)showBannerAdvert:(id<Yodo1MasAdvertBannerDelegate>)delegate {
    
}

@end
