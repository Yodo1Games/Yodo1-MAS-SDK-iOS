#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YD1VideoState) {
    kYD1VideoStateFail,
    kYD1VideoStateLoaded,
    kYD1VideoStateShow,
    kYD1VideoStateFinished,
    kYD1VideoStateClose,
};

typedef void(^YD1VideoCallback)(YD1VideoState state);

typedef NS_ENUM(NSInteger, YD1InterstitialState) {
    kYD1InterstitialStateFail,
    kYD1InterstitialStateLoaded,
    kYD1InterstitialStateShow,
    kYD1InterstitialStateFinished,
    kYD1InterstitialStateClicked,
    kYD1InterstitialStateClose,
};

typedef void(^YD1InterstitialCallback)(YD1InterstitialState state);

typedef NS_ENUM(NSInteger, YD1BannerState) {
    kYD1BannerStateFail,
    kYD1BannerStateLoaded,
    kYD1BannerStateShow,
    kYD1BannerStateFinished,
    kYD1BannerStateClicked,
    kYD1BannerStateClose,
};

typedef void(^Yodo1BannerCallback)(YD1BannerState state);
