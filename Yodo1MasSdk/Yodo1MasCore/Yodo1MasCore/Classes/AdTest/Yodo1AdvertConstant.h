#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YODO1VideoState) {
    kYODO1VideoStateFail,
    kYODO1VideoStateLoaded,
    kYODO1VideoStateShow,
    kYODO1VideoStateFinished,
    kYODO1VideoStateClose,
};

typedef void(^YD1VideoCallback)(YODO1VideoState state);

typedef NS_ENUM(NSInteger, YODO1InterstitialState) {
    kYODO1InterstitialStateFail,
    kYODO1InterstitialStateLoaded,
    kYODO1InterstitialStateShow,
    kYODO1InterstitialStateFinished,
    kYODO1InterstitialStateClicked,
    kYODO1InterstitialStateClose,
};

typedef void(^YODO1InterstitialCallback)(YODO1InterstitialState state);

typedef NS_ENUM(NSInteger, YODO1BannerState) {
    kYODO1BannerStateFail,
    kYODO1BannerStateLoaded,
    kYODO1BannerStateShow,
    kYODO1BannerStateFinished,
    kYODO1BannerStateClicked,
    kYODO1BannerStateClose,
};

typedef void(^Yodo1BannerCallback)(YODO1BannerState state);
