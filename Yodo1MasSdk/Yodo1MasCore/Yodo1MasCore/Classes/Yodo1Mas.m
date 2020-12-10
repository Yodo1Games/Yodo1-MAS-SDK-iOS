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
                NSLog(@"获取广告数据成功 - %@", res.data);
                [weakSelf doInitAdapter];
                [weakSelf doInitAdvert];
            } else {
                if (fail) {
                    fail([NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : @"获取广告配置失败"}]);
                }
            }
        } else {
            if (fail) {
                fail([NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : @"获取广告配置失败 - 解释配置数据失败"}]);
            }
            NSLog(@"获取广告配置失败 - 解释配置数据失败");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail) {
            fail(error);
        }
        NSLog(@"获取广告配置失败 - %@", error.localizedDescription);
    }];
}

- (void)doInitAdapter {
    NSDictionary *mediations = @{
        @"ADMOB_MEDIATION" : @"Yodo1MasAdMobMaxAdapter",
        @"APPLOVIN_MEDIATION" : @"Yodo1MasAppLovinMaxAdapter",
        @"IRONSOURCE_MEDIATION" : @"Yodo1MasIronSourceMaxAdapter"
    };
    
    NSDictionary *networks = @{
        @"ADMOB_NETWORK" : @"Yodo1MasAdMobAdapter",
        @"APPLOVIN_NETWORK" : @"Yodo1MasAppLovinAdapter",
        @"FACEBOOK_NETWORK" : @"Yodo1MasFacebookAdapter",
        @"INMOBI_NETWORK" : @"Yodo1MasInMobiAdapter",
        @"IRONSOURCE_NETWORK" : @"Yodo1MasIronSourceAdapter",
        @"TAPJOY_NETWORK" : @"Yodo1MasTapjoyAdapter",
        @"UNITYADS_NETWORK" : @"Yodo1MasUnityAdsAdapter",
        @"VUNGLE_NETWORK" : @"Yodo1MasVungleAdapter"
    };
    
    if (self.masInitConfig.mediation_list != nil && self.masInitConfig.mediation_list.count > 0) {
        for (Yodo1MasInitMediationInfo *info in self.masInitConfig.mediation_list) {
            NSString *key = info.name;
            NSString *value = mediations[key];
            [self doInitAdapter:key value:value appId:info.app_id appKey:info.app_key];
        }
    }
    
    if (self.masInitConfig.ad_network_list != nil && self.masInitConfig.ad_network_list.count > 0) {
        for (Yodo1MasInitNetworkInfo *info in self.masInitConfig.ad_network_list) {
            NSString *key = info.ad_network_name;
            NSString *value = networks[key];
            [self doInitAdapter:key value:value appId:info.ad_network_app_id appKey:info.ad_network_app_key];
        }
    }
}

- (void)doInitAdapter:(NSString *)key value:(NSString *)value appId:(NSString *)appId appKey:(NSString *)appKey {
    if (value && value.length > 0) {
        Class c = NSClassFromString(value);
        NSObject *o = c != nil ? [[c alloc] init] : nil;
        if (o != nil && [o isKindOfClass:[Yodo1MasAdapterBase class]]) {
            Yodo1MasAdapterConfig *config = [[Yodo1MasAdapterConfig alloc] init];
            config.name = key;
            config.appId = appId;
            config.appKey = appKey;
            Yodo1MasAdapterBase *adapter = (Yodo1MasAdapterBase *)o;
            self.mediations[key] = adapter;
            [adapter initWithConfig:config successful:^(NSString *advertCode) {
                NSLog(@"Adapter初始化成功 - %@:%@", key, value);
            } fail:^(NSString *advertCode, NSError *error) {
                NSLog(@"Adapter初始化失败 - %@:%@, %@", key, value, error.description);
            }];
        } else {
            if (o == nil) {
                NSLog(@"未集成相应Adapter -  %@", value);
            } else {
                NSLog(@"Adapter未继承Yodo1MasAdapterBase - %@", key);
            }
        }
    } else {
        NSLog(@"初始化Adapter - 未找到指定Adapter,SDK版本过低: - %@", key);
    }
}

- (void)doInitAdvert {
    if (self.masNetworkConfig.reward != nil) {
        [self doInitAdvert:self.masNetworkConfig.reward type:Yodo1MasAdvertTypeReward];
    }
    if (self.masNetworkConfig.interstitial != nil) {
        [self doInitAdvert:self.masNetworkConfig.interstitial type:Yodo1MasAdvertTypeInterstitial];
    }
    if (self.masNetworkConfig.banner != nil) {
        [self doInitAdvert:self.masNetworkConfig.banner type:Yodo1MasAdvertTypeBanner];
    }
}

- (void)doInitAdvert:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdvertType)type {
    if (config.mediation_list != nil && config.mediation_list.count > 0) {
        for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
            NSString *mediationName = mediation.mediation_name;
            NSString *unitId = mediation.ad_unit_id;
            if (mediationName != nil && unitId != nil && mediation.mediation_active) {
                Yodo1MasAdapterBase *adapter = self.mediations[mediationName];
                if (adapter != nil) {
                    switch (type) {
                        case Yodo1MasAdvertTypeReward: {
                            adapter.rewardPlacementId = unitId;
                            break;
                        }
                        case Yodo1MasAdvertTypeInterstitial: {
                            adapter.interstitialPlacementId = unitId;
                            break;
                        }
                        case Yodo1MasAdvertTypeBanner: {
                            adapter.bannerPlacementId = unitId;
                            break;
                        }
                    }
                }
            }
        }
    }
}

- (BOOL)isAdvertLoaded:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdvertType)type {
    BOOL isLoaded = NO;
    if (config != nil) {
        if (config.mediation_list != nil && config.mediation_list.count > 0) {
            for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
                NSString *name = mediation.mediation_name;
                if (name != nil && name.length > 0 && mediation.mediation_active) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        isLoaded = [adapter isAdvertLoaded:type];
                    }
                }
            }
        }
        
        if (!isLoaded && config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
            for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
                NSString *name = waterfall.ad_network_name;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        isLoaded = [adapter isAdvertLoaded:type];
                    }
                }
                if (isLoaded) break;
            }
        }
    }
    return isLoaded;
}

- (void)loadAdvert:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdvertType)type {
    if (config != nil) {
        if (config.mediation_list != nil && config.mediation_list.count > 0) {
            for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
                NSString *name = mediation.mediation_name;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        [adapter loadAdvert:type];
                    }
                }
            }
        }
        
        if (config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
            for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
                NSString *name = waterfall.ad_network_name;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        [adapter loadAdvert:type];
                    }
                }
            }
        }
    }
}

- (NSMutableArray<Yodo1MasAdapterBase *> *)getAdapters:(Yodo1MasNetworkAdvert *)config {
    NSMutableArray<Yodo1MasAdapterBase *> *adapters = [NSMutableArray array];
    if (config.mediation_list != nil && config.mediation_list.count > 0) {
        for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
            NSString *name = mediation.mediation_name;
            if (name != nil && name.length > 0) {
                Yodo1MasAdapterBase *adapter = self.mediations[name];
                if (adapter != nil) {
                    [adapters addObject:adapter];
                }
            }
        }
    }
    
    if (config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
        for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
            NSString *name = waterfall.ad_network_name;
            if (name != nil && name.length > 0) {
                Yodo1MasAdapterBase *adapter = self.mediations[name];
                if (adapter != nil) {
                    [adapters addObject:adapter];
                }
            }
        }
    }
    return adapters;
}

- (void)showAdvert:(UIViewController *)controller config:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdvertType)type callback:(Yodo1MasAdvertCallback)callback {
    if (config != nil) {
        NSMutableArray<Yodo1MasAdapterBase *> *adapters = [self getAdapters:config];
        __weak Yodo1MasAdvertCallback block = ^(Yodo1MasAdvertEvent event, NSError * _Nonnull error) {
            switch (event) {
                case Yodo1MasAdvertEventError: {
                    [adapters removeObjectAtIndex:0];
                    if (adapters.count > 0) {
                        [adapters.firstObject showAdvert:controller type:type callback:block];
                    } else {
                        if (callback != nil) {
                            callback(event, error);
                        }
                    }
                    break;
                }
                default: {
                    if (callback != nil) {
                        callback(event, error);
                    }
                    break;
                }
            }
        };
        if (adapters.count > 0) {
            [adapters.firstObject showAdvert:controller type:type callback:block];
        } else {
            if (callback != nil) {
                callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
            }
        }
    } else {
        if (callback != nil) {
            callback(Yodo1MasAdvertEventError, [NSError errorWithDomain:@"" code:0 userInfo:@{}]);
        }
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdvertLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.reward type:Yodo1MasAdvertTypeReward];
}

- (void)loadRewardAdvert {
    [self loadAdvert:self.masNetworkConfig.reward type:Yodo1MasAdvertTypeReward];
}

- (void)showRewardAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    Yodo1MasNetworkAdvert *config = self.masNetworkConfig != nil ? self.masNetworkConfig.reward : nil;
    [self showAdvert:controller config:config type:Yodo1MasAdvertTypeReward callback:callback];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.interstitial type:Yodo1MasAdvertTypeInterstitial];
}

- (void)loadInterstitialAdvert {
    [self loadAdvert:self.masNetworkConfig.interstitial type:Yodo1MasAdvertTypeInterstitial];
}

- (void)showInterstitialAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    Yodo1MasNetworkAdvert *config = self.masNetworkConfig != nil ? self.masNetworkConfig.interstitial : nil;
    [self showAdvert:controller config:config type:Yodo1MasAdvertTypeReward callback:callback];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.banner type:Yodo1MasAdvertTypeBanner];
}

- (void)loadBannerAdvert {
    [self loadAdvert:self.masNetworkConfig.banner type:Yodo1MasAdvertTypeBanner];
}

- (void)showBannerAdvert:(UIViewController *)controller callback:(Yodo1MasAdvertCallback)callback {
    Yodo1MasNetworkAdvert *config = self.masNetworkConfig != nil ? self.masNetworkConfig.banner : nil;
    [self showAdvert:controller config:config type:Yodo1MasAdvertTypeReward callback:callback];
}

@end
