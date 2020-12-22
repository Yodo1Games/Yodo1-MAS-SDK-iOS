//
//  Yodo1Alert.h
//
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    extern void MasUnitySendMessage(const char* obj, const char* method, const char* msg);
#if UNITY_VERSION < 500
    extern void MasUnityPause(bool pause);
#else
    extern void MasUnityPause(int pause);
#endif
    extern NSString* Yodo1MasCreateNSString(const char* string);
    extern char* Yodo1MasMakeStringCopy(const char* string);
    
#ifdef __cplusplus
}
#endif

