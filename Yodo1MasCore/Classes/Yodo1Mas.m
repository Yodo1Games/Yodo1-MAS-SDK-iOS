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
#if defined(__IPHONE_14_0)
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif
#import <AdSupport/AdSupport.h>

#define Yodo1MasGDPRUserConsent     @"Yodo1MasGDPRUserConsent"
#define Yodo1MasCOPPAAgeRestricted  @"Yodo1MasCOPPAAgeRestricted"
#define Yodo1MasCCPADoNotSell       @"Yodo1MasCCPADoNotSell"

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id gdpr = [defaults objectForKey:Yodo1MasGDPRUserConsent];
        _isGDPRUserConsent =  gdpr != nil ? [gdpr boolValue] : YES;
        
        id coppa = [defaults objectForKey:Yodo1MasCOPPAAgeRestricted];
        _isCOPPAAgeRestricted = coppa != nil ? [coppa boolValue] : NO;
        
        id ccpa = [defaults objectForKey:Yodo1MasCCPADoNotSell];
        _isCCPADoNotSell = ccpa != nil ? [ccpa boolValue] : NO;
    }
    return self;
}

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
#if defined(__IPHONE_14_0)
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            
        }];
    }
#endif
    
    __weak __typeof(self)weakSelf = self;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableString *url = [NSMutableString string];
#ifdef DEBUG
    NSString *api = [[NSUserDefaults standardUserDefaults] stringForKey:@"MockApi"];
    if (api != nil && api.length > 0) {
        [url appendString:api];
    } else {
        [url appendString:@"https://rivendell-dev.explorer.yodo1.com/init/"];
    }
    parameters[@"country"] = [NSLocale currentLocale].countryCode;
#else
    [url appendString:@"https://rivendell.explorer.yodo1.com/init/"];
#endif
    [url appendString:appId];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Yodo1MasResponse *res = [Yodo1MasResponse yy_modelWithJSON:responseObject];
#ifdef DEBUG
        // Mock
        NSString *api = [[NSUserDefaults standardUserDefaults] stringForKey:@"MockApi"];
        if (res.data == nil && api != nil && api.length > 0) {
            res.data = responseObject;
        }
#endif
        
        if (res != nil && res.data != nil) {
            Yodo1MasInitData *data = [Yodo1MasInitData yy_modelWithJSON:res.data];
            weakSelf.masInitConfig = data.mas_init_config;
            weakSelf.masNetworkConfig = data.ad_network_config;
            if (data.mas_init_config && data.ad_network_config) {
                NSLog(@"获取广告数据成功 - %@", res.data);
                [weakSelf doInitAdapter];
                [weakSelf doInitAdvert];
                if (successful) {
                    successful();
                }
            } else {
                if (fail) {
                    fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigGet message:@"get config failed"]);
                }
            }
        } else {
            if (fail) {
                fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigServer message:@"get config failed"]);
            }
            NSLog(@"获取广告配置失败 - 解释配置数据失败");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail) {
            fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigServer message:error.localizedDescription]);
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
            if (mediationName != nil && unitId != nil) {
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

- (void)setIsGDPRUserConsent:(BOOL)isGDPRUserConsent {
    if (isGDPRUserConsent != _isGDPRUserConsent) {
        _isGDPRUserConsent = isGDPRUserConsent;
        [[NSUserDefaults standardUserDefaults] setBool:_isGDPRUserConsent forKey:Yodo1MasGDPRUserConsent];
        
        for (Yodo1MasAdapterBase *adapter in _mediations.allValues) {
            [adapter updatePrivacy];
        }
    }
}

- (void)setIsCOPPAAgeRestricted:(BOOL)isCOPPAAgeRestricted {
    if (isCOPPAAgeRestricted != _isCOPPAAgeRestricted) {
        _isCOPPAAgeRestricted = isCOPPAAgeRestricted;
        [[NSUserDefaults standardUserDefaults] setBool:_isCOPPAAgeRestricted forKey:Yodo1MasCOPPAAgeRestricted];
        
        for (Yodo1MasAdapterBase *adapter in _mediations.allValues) {
            [adapter updatePrivacy];
        }
    }
}

- (void)setIsCCPADoNotSell:(BOOL)isCCPADoNotSell {
    if (isCCPADoNotSell != _isCCPADoNotSell) {
        _isCCPADoNotSell = isCCPADoNotSell;
        [[NSUserDefaults standardUserDefaults] setBool:_isCCPADoNotSell forKey:Yodo1MasCCPADoNotSell];
        
        for (Yodo1MasAdapterBase *adapter in _mediations.allValues) {
            [adapter updatePrivacy];
        }
    }
}

- (BOOL)isAdvertLoaded:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdvertType)type {
    BOOL isLoaded = NO;
    if (config != nil) {
        if (config.mediation_list != nil && config.mediation_list.count > 0) {
            for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
                NSString *name = mediation.mediation_name;
                if (name != nil && name.length > 0) {
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

- (void)showAdvert:(Yodo1MasAdvertType)type {
    [self showAdvert:type object:nil];
}

- (void)showAdvert:(Yodo1MasAdvertType)type object: (NSDictionary *)object {
    Yodo1MasNetworkAdvert *config = nil;
    switch (type) {
        case Yodo1MasAdvertTypeReward:
            config = self.masNetworkConfig != nil ? self.masNetworkConfig.reward : nil;
            break;
        case Yodo1MasAdvertTypeInterstitial:
            config = self.masNetworkConfig != nil ? self.masNetworkConfig.interstitial : nil;
            break;
        case Yodo1MasAdvertTypeBanner:
            config = self.masNetworkConfig != nil ? self.masNetworkConfig.banner : nil;
            break;
    }
    
    
    if (config != nil) {
        NSMutableArray<Yodo1MasAdapterBase *> *adapters = [self getAdapters:config];
        __weak Yodo1MasAdvertCallback block = ^(Yodo1MasAdvertEvent *event) {
            switch (event.code) {
                case Yodo1MasAdvertEventCodeOpened: {
                    [adapters removeAllObjects];
                    [self callbackWithEvent:event];
                    break;
                }
                case Yodo1MasAdvertEventCodeError: {
                    [adapters removeObjectAtIndex:0];
                    if (adapters.count > 0) {
                        [adapters.firstObject showAdvert:type callback:block object:object];
                    } else {
                        [self callbackWithEvent:event];
                    }
                    break;
                }
                default: {
                    [self callbackWithEvent:event];
                    break;
                }
            }
        };
        if (adapters.count > 0) {
            [adapters.firstObject showAdvert:type callback:block object:object];
        } else {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertAadpterNull message:@"ad adapters is null"];
            Yodo1MasAdvertEvent *event = [[Yodo1MasAdvertEvent alloc] initWithCode:Yodo1MasAdvertEventCodeError type:type message:@"" error:error];
            [self callbackWithEvent:event];
        }
    } else {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdvertConfigNull message:@"ad config is null"];
        Yodo1MasAdvertEvent *event = [[Yodo1MasAdvertEvent alloc] initWithCode:Yodo1MasAdvertEventCodeError type:type message:@"" error:error];
        [self callbackWithEvent:event];
    }
}

- (void)callbackWithEvent:(Yodo1MasAdvertEvent *)event {
    switch (event.type) {
        case Yodo1MasAdvertTypeReward: {
            id<Yodo1MasRewardAdvertDelegate> delegate = self.rewardAdvertDelegate;
            if (delegate != nil) {
                switch (event.code) {
                    case Yodo1MasAdvertEventCodeOpened: {
                        if ([delegate respondsToSelector:@selector(onAdvertOpened:)]) {
                            [delegate onAdvertOpened:event];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeClosed: {
                        if ([delegate respondsToSelector:@selector(onAdvertClosed:)]) {
                            [delegate onAdvertClosed:event];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeError: {
                        if ([delegate respondsToSelector:@selector(onAdvertError:error:)]) {
                            [delegate onAdvertError:event error:event.error];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeRewardEarned: {
                        if ([delegate respondsToSelector:@selector(onAdvertRewardEarned:)]) {
                            [delegate onAdvertRewardEarned:event];
                        }
                        break;
                    }
                }
            }
            break;
        }

        case Yodo1MasAdvertTypeInterstitial: {
            id delegate = self.interstitialAdvertDelegate;
            if (delegate != nil) {
                switch (event.code) {
                    case Yodo1MasAdvertEventCodeOpened: {
                        if ([delegate respondsToSelector:@selector(onAdvertOpened:)]) {
                            [delegate onAdvertOpened:event];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeClosed: {
                        if ([delegate respondsToSelector:@selector(onAdvertClosed:)]) {
                            [delegate onAdvertClosed:event];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeError: {
                        if ([delegate respondsToSelector:@selector(onAdvertError:error:)]) {
                            [delegate onAdvertError:event error:event.error];
                        }
                        break;
                    }
                }
            }
            break;
        }
        case Yodo1MasAdvertTypeBanner: {
            id delegate = self.bannerAdvertDelegate;
            if (delegate != nil) {
                switch (event.code) {
                    case Yodo1MasAdvertEventCodeOpened: {
                        if ([delegate respondsToSelector:@selector(onAdvertOpened:)]) {
                            [delegate onAdvertOpened:event];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeClosed: {
                        if ([delegate respondsToSelector:@selector(onAdvertClosed:)]) {
                            [delegate onAdvertClosed:event];
                        }
                        break;
                    }
                    case Yodo1MasAdvertEventCodeError: {
                        if ([delegate respondsToSelector:@selector(onAdvertError:error:)]) {
                            [delegate onAdvertError:event error:event.error];
                        }
                        break;
                    }
                }
            }
            break;
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

- (void)showRewardAdvert {
    [self showAdvert:Yodo1MasAdvertTypeReward];
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdvertLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.interstitial type:Yodo1MasAdvertTypeInterstitial];
}

- (void)loadInterstitialAdvert {
    [self loadAdvert:self.masNetworkConfig.interstitial type:Yodo1MasAdvertTypeInterstitial];
}

- (void)showInterstitialAdvert {
    [self showAdvert:Yodo1MasAdvertTypeInterstitial];
}

#pragma mark - 横幅广告
- (BOOL)isBannerAdvertLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.banner type:Yodo1MasAdvertTypeBanner];
}

- (void)loadBannerAdvert {
    [self loadAdvert:self.masNetworkConfig.banner type:Yodo1MasAdvertTypeBanner];
}

- (void)showBannerAdvert {
    [self showBannerAdvert:Yodo1MasBannerAlignBottom | Yodo1MasBannerAlignHorizontalCenter];
}

- (void)showBannerAdvert:(Yodo1MasBannerAlign)align {
    [self showAdvert:Yodo1MasAdvertTypeBanner object:@{KeyBannerAlign : @(align)}];
}

@end
