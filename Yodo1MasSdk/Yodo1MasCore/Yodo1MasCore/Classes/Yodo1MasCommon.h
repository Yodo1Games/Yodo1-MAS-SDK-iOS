//
//  Yodo1MasCommon.h
//  Pods
//
//  Created by ZhouYuzhen on 2020/12/17.
//

#ifndef Yodo1MasCommon_h
#define Yodo1MasCommon_h

typedef enum {
    Yodo1MasAdvertTypeReward = 1,
    Yodo1MasAdvertTypeInterstitial = 2,
    Yodo1MasAdvertTypeBanner = 3
} Yodo1MasAdvertType;

typedef enum {
    Yodo1MasAdvertEventCodeError = -1,
    Yodo1MasAdvertEventCodeOpened = 1001,
    Yodo1MasAdvertEventCodeClosed = 1002,
    Yodo1MasAdvertEventCodeRewardEarned = 2001
} Yodo1MasAdvertEventCode;

typedef enum {
    Yodo1MasErrorCodeUnknown = -1,
    Yodo1MasErrorCodeConfigGet = -1000,
    Yodo1MasErrorCodeConfigNetwork = -1001,
    Yodo1MasErrorCodeConfigServer = -1002,
    Yodo1MasErrorCodeAdvertConfigNull = -2001, // ad adapter is null
    Yodo1MasErrorCodeAdvertAadpterNull = -2002, // ad adapter is null
    Yodo1MasErrorCodeAdvertUninitialized = -2003, // ad adapter uninitialized
    Yodo1MasErrorCodeAdvertNoLoaded = -2004, // ad no loaded
    Yodo1MasErrorCodeAdvertLoadFail = -2005, // ad load error
    Yodo1MasErrorCodeAdvertShowFail = -2006
} Yodo1MasErrorCode;

#endif /* Yodo1MasCommon_h */
