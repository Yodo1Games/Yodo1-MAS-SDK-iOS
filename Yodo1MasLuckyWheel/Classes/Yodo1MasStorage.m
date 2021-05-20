//
//  Yodo1MasStorage.m
//
//  Created by yixian huang on 2020/5/5.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1MasStorage.h"
#import <Security/Security.h>
#import <AdSupport/AdSupport.h>

@implementation Yodo1MasStorage

static YYCache* _sharedCached = nil;
+ (YYCache *)cached {
    if (_sharedCached == nil) {
        _sharedCached = [[YYCache alloc]initWithPath:[Yodo1MasStorage docPath]];
    }
    return _sharedCached;
}

+ (NSString* )docPath{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/__yd1mascache__"];
    NSLog(@"docPath:%@",path);
    return path;
}

+ (void)saveKeychainWithService:(NSString *)service str:(NSString *)str {
    [self save:service data:str];
}

+ (NSString *)keychainWithService:(NSString *)service {
    NSString *str = (NSString *)[self load:service];
    if ([str isKindOfClass:[NSString class]]) {
        return str;
    }
    [Yodo1MasStorage deleteKeyData:service];
    return @"";
}

+ (NSString *)keychainUUID {
    NSString* bid = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *strUUID = (NSString *)[Yodo1MasStorage load:bid];
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""]|| !strUUID) {
        //生成一个uuid的方法
        strUUID = [NSUUID UUID].UUIDString;
        //将该uuid保存到keychain
        [Yodo1MasStorage saveKeychainWithService:bid str:strUUID];
    }
    return strUUID;
}

+ (NSString *)keychainDeviceId {
    NSString* __deviceId = (NSString *)[Yodo1MasStorage load:@"__yodo1__device__id__"];
    if ([__deviceId isEqualToString:@""]||!__deviceId) {
        __deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if ([__deviceId hasPrefix:@"00000000"]||[__deviceId isEqualToString:@""]) {
            __deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        }
        if ([__deviceId isEqualToString:@""]) {
            __deviceId = [NSUUID UUID].UUIDString;
        }
        [Yodo1MasStorage saveKeychainWithService:@"__yodo1__device__id__" str:__deviceId];
    }
    return __deviceId;
}

#pragma mark private
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [Yodo1MasStorage getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery,(CFTypeRef*)&keyData) ==noErr){
        @try{
            ret =[NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)keyData];
        }@catch(NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@",service, e);
        }@finally{
            
        }
    }
    if (keyData) {
        CFRelease(keyData);
    }
    return ret;
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service,(id)kSecAttrService,
            service,(id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    // Get search dictionary
    NSMutableDictionary *keychainQuery = [Yodo1MasStorage getKeychainQuery:service];
    // Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    // Add new object to searchdictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data]forKey:(id)kSecValueData];
    // Add item to keychain with the searchdictionary
    SecItemAdd((CFDictionaryRef)keychainQuery,NULL);
}

+ (void)deleteKeyData:(NSString *)service {
    NSMutableDictionary *keychainQuery = [Yodo1MasStorage getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
