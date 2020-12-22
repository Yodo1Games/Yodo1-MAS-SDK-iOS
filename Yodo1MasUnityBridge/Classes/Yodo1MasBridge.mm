//
//  UnityYodo1Mas.mm
//  Pods
//
//  Created by sunmeng on 2020/12/21.
//

#import "Yodo1MasBridge.h"
#import "Yodo1Mas.h"
#import "Yodo1MasUnityTool.h"

@interface Yodo1MasUtils : NSObject

+ (UIViewController*)getRootViewController;

+ (UIViewController*)topMostViewController:(UIViewController*)controller;

+ (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error;

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error;

+ (NSString*)convertToInitJsonString:(int)success error:(NSString*)errorMsg;

+ (NSString*)getSendMessage:(int)flag data:(NSString*)data;

@end

@implementation Yodo1MasUtils

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
        NSString* errorJsonString = [Yodo1MasUtils stringWithJSONObject:[error getJsonObject] error:nil];
        [dict setObject:errorJsonString forKey:@"error"];
    }
    
    NSString* data = [Yodo1MasUtils stringWithJSONObject:dict error:nil];
    return data;
}

+ (NSString*)getSendMessage:(int)flag data:(NSString*)data {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:flag] forKey:@"flag"];
    [dict setObject:data forKey:@"data"];
    
    NSError* parseJSONError = nil;
    NSString* msg = [Yodo1MasUtils stringWithJSONObject:dict error:&parseJSONError];
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
    
    NSString* m_methodName = Yodo1MasCreateNSString(callbackMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d callback method isn't set!");
    
    [[Yodo1Mas sharedInstance] initWithAppId:m_appKey successful:^{
        NSString* data = [Yodo1MasUtils convertToInitJsonString:1 masError:nil];
        NSString* msg = [Yodo1MasUtils getSendMessage:0 data:data];
        MasUnitySendMessage(gameObjectName, callbackMethodName, [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    } fail:^(Yodo1MasError * _Nonnull error) {
        NSString* data = [Yodo1MasUtils convertToInitJsonString:0 masError:error];
        NSString* msg = [Yodo1MasUtils getSendMessage:0 data:data];
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
    return [[Yodo1Mas sharedInstance] isBannerAdvertLoaded];
}
//
void UnityShowBanner(const char* gameObjectName, const char* callbackMethodName)
{
    [[Yodo1Mas sharedInstance] showBannerAdvert:[Yodo1MasUtils getRootViewController] callback:^(Yodo1MasAdvertEvent * adEvent) {
            NSString* data = [Yodo1MasUtils stringWithJSONObject:adEvent.getJsonObject error:nil];
            NSString* msg = [Yodo1MasUtils getSendMessage:1 data:data];
            MasUnitySendMessage(gameObjectName, callbackMethodName, [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }];
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
    [[Yodo1Mas sharedInstance] showInterstitialAdvert:[Yodo1MasUtils getRootViewController] callback:^(Yodo1MasAdvertEvent * adEvent) {
        NSString* data = [Yodo1MasUtils stringWithJSONObject:adEvent.getJsonObject error:nil];
        NSString* msg = [Yodo1MasUtils getSendMessage:1 data:data];
        MasUnitySendMessage(gameObjectName, callbackMethodName, [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }];
}

#pragma mark - Unity3dVideo

bool Unity3dVideoIsReady()
{
    return [[Yodo1Mas sharedInstance] isRewardAdvertLoaded];
}

void Unity3dShowVideo(const char* gameObjectName, const char* callbackMethodName)
{
    [[Yodo1Mas sharedInstance] showBannerAdvert:[Yodo1MasUtils getRootViewController] callback:^(Yodo1MasAdvertEvent * adEvent) {
            NSString* data = [Yodo1MasUtils stringWithJSONObject:adEvent.getJsonObject error:nil];
            NSString* msg = [Yodo1MasUtils getSendMessage:1 data:data];
            MasUnitySendMessage(gameObjectName, callbackMethodName, [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }];
}

}
#endif
