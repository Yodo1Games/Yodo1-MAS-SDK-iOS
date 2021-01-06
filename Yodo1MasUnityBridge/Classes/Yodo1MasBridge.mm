//
//  UnityYodo1Mas.mm
//  Pods
//
//  Created by sunmeng on 2020/12/21.
//

#import "Yodo1MasBridge.h"
#import "Yodo1Mas.h"
#import "Yodo1MasUnityTool.h"

static NSString* kYodo1MasGameObject;
static NSString* kYodo1MasMethodName;

@interface Yodo1MasBridge : NSObject <Yodo1MasRewardAdvertDelegate, Yodo1MasInterstitialAdvertDelegate, Yodo1MasBannerAdvertDelegate>

+ (UIViewController*)getRootViewController;

+ (UIViewController*)topMostViewController:(UIViewController*)controller;

+ (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error;

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error;

+ (NSString*)convertToInitJsonString:(int)success error:(NSString*)errorMsg;

+ (NSString*)getSendMessage:(int)flag data:(NSString*)data;

+ (Yodo1MasBridge *)sharedInstance;

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail;

- (BOOL)isRewardAdvertLoaded;
- (void)showRewardAdvert;

- (BOOL)isInterstitialAdvertLoaded;
- (void)showInterstitialAdvert;

- (BOOL)isBannerAdvertLoaded;
- (void)showBannerAdvert;
- (void)showBannerAdvert:(Yodo1MasBannerAlign)align;
@end

@implementation Yodo1MasBridge

+ (Yodo1MasBridge *)sharedInstance {
    static Yodo1MasBridge *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1MasBridge alloc] init];
    });
    return _instance;
}

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
    [Yodo1Mas sharedInstance].rewardAdvertDelegate = self;
    [Yodo1Mas sharedInstance].interstitialAdvertDelegate = self;
    [Yodo1Mas sharedInstance].bannerAdvertDelegate = self;
    
    [[Yodo1Mas sharedInstance] initWithAppId:appId successful:successful fail:fail];
}

- (BOOL)isRewardAdvertLoaded {
    return [[Yodo1Mas sharedInstance] isRewardAdvertLoaded];
}
- (void)showRewardAdvert {
    [[Yodo1Mas sharedInstance] showRewardAdvert];
}

- (BOOL)isInterstitialAdvertLoaded {
    return [[Yodo1Mas sharedInstance] isInterstitialAdvertLoaded];
}
- (void)showInterstitialAdvert {
    [[Yodo1Mas sharedInstance] showInterstitialAdvert];
}

- (BOOL)isBannerAdvertLoaded {
    return [[Yodo1Mas sharedInstance] isBannerAdvertLoaded];
}
- (void)showBannerAdvert {
    [[Yodo1Mas sharedInstance] showBannerAdvert];
}
- (void)showBannerAdvert:(Yodo1MasBannerAlign)align {
    [[Yodo1Mas sharedInstance] showBannerAdvert:align];
}

#pragma mark - Yodo1MasAdvertDelegate
- (void)onAdvertOpened:(Yodo1MasAdvertEvent *)event {
    if (event == nil) {
        return;
    }
    NSString* data = [Yodo1MasBridge stringWithJSONObject:event.getJsonObject error:nil];
    NSString* msg = [Yodo1MasBridge getSendMessage:1 data:data];
    MasUnitySendMessage([kYodo1MasGameObject cStringUsingEncoding:NSUTF8StringEncoding], [kYodo1MasMethodName cStringUsingEncoding:NSUTF8StringEncoding], [msg cStringUsingEncoding:NSUTF8StringEncoding]);

}

- (void)onAdvertClosed:(Yodo1MasAdvertEvent *)event {
    if (event == nil) {
        return;
    }
    NSString* data = [Yodo1MasBridge stringWithJSONObject:event.getJsonObject error:nil];
    NSString* msg = [Yodo1MasBridge getSendMessage:1 data:data];
    MasUnitySendMessage([kYodo1MasGameObject cStringUsingEncoding:NSUTF8StringEncoding], [kYodo1MasMethodName cStringUsingEncoding:NSUTF8StringEncoding], [msg cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)onAdvertError:(Yodo1MasAdvertEvent *)event error:(Yodo1MasError *)error {
    if (event == nil) {
        return;
    }
    NSString* data = [Yodo1MasBridge stringWithJSONObject:event.getJsonObject error:nil];
    NSString* msg = [Yodo1MasBridge getSendMessage:1 data:data];
    MasUnitySendMessage([kYodo1MasGameObject cStringUsingEncoding:NSUTF8StringEncoding], [kYodo1MasMethodName cStringUsingEncoding:NSUTF8StringEncoding], [msg cStringUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark - Yodo1MasRewardAdvertDelegate
- (void)onAdvertRewardEarned:(Yodo1MasAdvertEvent *)event {
    if (event == nil) {
        return;
    }
    NSString* data = [Yodo1MasBridge stringWithJSONObject:event.getJsonObject error:nil];
    NSString* msg = [Yodo1MasBridge getSendMessage:1 data:data];
    MasUnitySendMessage([kYodo1MasGameObject cStringUsingEncoding:NSUTF8StringEncoding], [kYodo1MasMethodName cStringUsingEncoding:NSUTF8StringEncoding], [msg cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (UIViewController*)getRootViewController {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray* windows = [[UIApplication sharedApplication] windows];
        for (UIWindow* _window in windows) {
            if (_window.windowLevel == UIWindowLevelNormal) {
                window = _window;
                break;
            }
        }
    }
    UIViewController* viewController = nil;
    for (UIView* subView in [window subviews]) {
        UIResponder* responder = [subView nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            viewController = [self topMostViewController:(UIViewController*)responder];
        }
    }
    if (!viewController) {
        viewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    return viewController;
}

+ (UIViewController*)topMostViewController:(UIViewController*)controller {
    BOOL isPresenting = NO;
    do {
        // this path is called only on iOS 6+, so -presentedViewController is fine here.
        UIViewController* presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}

+ (NSString*)stringWithJSONObject:(id)obj error:(NSError**)error {
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

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error {
    if (str) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            return [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingAllowFragments
                                                     error:error];
        }
    }
    return nil;
}

+ (NSString*)convertToInitJsonString:(int)success masError:(Yodo1MasError*) error {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:success] forKey:@"success"];
    
    if (error != nil) {
        NSString* errorJsonString = [Yodo1MasBridge stringWithJSONObject:[error getJsonObject] error:nil];
        [dict setObject:errorJsonString forKey:@"error"];
    }
    
    NSString* data = [Yodo1MasBridge stringWithJSONObject:dict error:nil];
    return data;
}

+ (NSString*)getSendMessage:(int)flag data:(NSString*)data {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:flag] forKey:@"flag"];
    [dict setObject:data forKey:@"data"];
    
    NSError* parseJSONError = nil;
    NSString* msg = [Yodo1MasBridge stringWithJSONObject:dict error:&parseJSONError];
    NSString* jsonError = @"";
    if(parseJSONError){
        jsonError = @"Convert result to json failed!";
    }
    return msg;
}

@end

#pragma mark- ///Unity3d

#ifdef __cplusplus

extern "C" {

#pragma mark - Privacy

void Unity3dSetUserConsent(BOOL consent)
{
    [Yodo1Mas sharedInstance].isGDPRUserConsent = consent;
}

bool Unity3dIsUserConsent()
{
    return [Yodo1Mas sharedInstance].isGDPRUserConsent;
}

void Unity3dSetTagForUnderAgeOfConsent(BOOL isBelowConsentAge)
{
    [Yodo1Mas sharedInstance].isCOPPAAgeRestricted = isBelowConsentAge;
}

bool Unity3dIsTagForUnderAgeOfConsent()
{
    return [Yodo1Mas sharedInstance].isCOPPAAgeRestricted;
}

void Unity3dSetDoNotSell(BOOL doNotSell)
{
    [Yodo1Mas sharedInstance].isCCPADoNotSell = doNotSell;
}

bool Unity3dIsDoNotSell()
{
    return [Yodo1Mas sharedInstance].isCCPADoNotSell;
}

#pragma mark - Initialize

void Unity3dInitWithAppKey(const char* appKey,const char* gameObjectName, const char* callbackMethodName)
{
    NSString* m_appKey = Yodo1MasCreateNSString(appKey);
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
    
    NSString* m_gameObject = Yodo1MasCreateNSString(gameObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    kYodo1MasGameObject = m_gameObject;
    
    NSString* m_methodName = Yodo1MasCreateNSString(callbackMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d callback method isn't set!");
    kYodo1MasMethodName = m_methodName;
    
    [[Yodo1MasBridge sharedInstance] initWithAppId:m_appKey successful:^{
        NSString* data = [Yodo1MasBridge convertToInitJsonString:1 masError:nil];
        NSString* msg = [Yodo1MasBridge getSendMessage:0 data:data];
        MasUnitySendMessage(gameObjectName, callbackMethodName, [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    } fail:^(Yodo1MasError * _Nonnull error) {
        NSString* data = [Yodo1MasBridge convertToInitJsonString:0 masError:error];
        NSString* msg = [Yodo1MasBridge getSendMessage:0 data:data];
        MasUnitySendMessage(gameObjectName, callbackMethodName, [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }];
}

#pragma mark - Unity3dBanner

//void Unity3dSetBannerAlign(Yodo1AdsCBannerAdAlign align)
//{
//    [Yodo1Ads setBannerAlign:(Yodo1AdsBannerAdAlign)align];
//}
//
//void Unity3dSetBannerOffset(float x,float y)
//{
//    [Yodo1Ads setBannerOffset:CGPointMake(x,y)];
//}
//
//void Unity3dSetBannerScale(float sx,float sy)
//{
//    [Yodo1Ads setBannerScale:sx sy:sy];
//}
//
bool Unity3dBannerIsReady()
{
    return [[Yodo1MasBridge sharedInstance] isBannerAdvertLoaded];
}

void UnityShowBanner(const char* gameObjectName, const char* callbackMethodName)
{
    NSString* m_gameObject = Yodo1MasCreateNSString(gameObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    kYodo1MasGameObject = m_gameObject;
    
    NSString* m_methodName = Yodo1MasCreateNSString(callbackMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d callback method isn't set!");
    kYodo1MasMethodName = m_methodName;
    
    [[Yodo1MasBridge sharedInstance] showBannerAdvert];
}

void UnityShowBannerWithAlign(int align, const char* gameObjectName, const char* callbackMethodName)
{
    NSString* m_gameObject = Yodo1MasCreateNSString(gameObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    kYodo1MasGameObject = m_gameObject;
    
    NSString* m_methodName = Yodo1MasCreateNSString(callbackMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d callback method isn't set!");
    kYodo1MasMethodName = m_methodName;
    
    [[Yodo1MasBridge sharedInstance] showBannerAdvert:(Yodo1MasBannerAlign)align];
}

//
//void UnityShowBannerWithPlacement(const char* placement_id) {
//    [Yodo1Ads showBanner:Yodo1CreateNSString(placement_id)];
//}
//
//void Unity3dHideBanner()
//{
//    [Yodo1Ads hideBanner];
//}
//
//void Unity3dRemoveBanner()
//{
//    [Yodo1Ads removeBanner];
//}

#pragma mark - Unity3dInterstitial

bool Unity3dInterstitialIsReady()
{
    return [[Yodo1Mas sharedInstance] isInterstitialAdvertLoaded];
}

void Unity3dShowInterstitial(const char* gameObjectName, const char* callbackMethodName)
{
    NSString* m_gameObject = Yodo1MasCreateNSString(gameObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    kYodo1MasGameObject = m_gameObject;
    
    NSString* m_methodName = Yodo1MasCreateNSString(callbackMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d callback method isn't set!");
    kYodo1MasMethodName = m_methodName;
    
    [[Yodo1MasBridge sharedInstance] showInterstitialAdvert];
}

#pragma mark - Unity3dVideo

bool Unity3dVideoIsReady()
{
    return [[Yodo1Mas sharedInstance] isRewardAdvertLoaded];
}

void Unity3dShowVideo(const char* gameObjectName, const char* callbackMethodName)
{
    NSString* m_gameObject = Yodo1MasCreateNSString(gameObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    kYodo1MasGameObject = m_gameObject;
    
    NSString* m_methodName = Yodo1MasCreateNSString(callbackMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d callback method isn't set!");
    kYodo1MasMethodName = m_methodName;
    
    [[Yodo1MasBridge sharedInstance] showRewardAdvert];
}

}
#endif
