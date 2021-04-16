#import "Yodo1AdsManager.h"
#import "Yodo1InterstitialViewController.h"
#import "Yodo1BannerView.h"
#import "Yodo1VideoViewController.h"

@interface Yodo1AdsManager ()  {
    
    BOOL isInited;
}

@property (nonatomic, strong) YD1VideoCallback kVideoCallbak;
@property (nonatomic, strong) YD1InterstitialCallback kIntersCallbak;
@property (nonatomic, strong) Yodo1BannerCallback kBannerCallbak;

@property (nonatomic, strong) Yodo1InterstitialViewController *kInterstitialView;
@property (nonatomic, strong) Yodo1BannerView *kBannerView;
@property (nonatomic, strong) Yodo1VideoViewController *kVideoViewController;

- (BOOL)isLandscape;

@end

@implementation Yodo1AdsManager

static Yodo1AdsManager* _instance = nil;
+ (Yodo1AdsManager*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1AdsManager alloc]init];
    });
    return _instance;
}


#pragma mark- Video

- (BOOL)isLandscape {
    UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    return screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight;
}

- (void)initAdvert {
    if (isInited) {
        return;
    }
    isInited = YES;

    
    //Interstitial
    __weak Yodo1AdsManager *weakSelfInters = self;
    [self.kInterstitialView setCallbak:^(YD1InterstitialState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (state == kYD1InterstitialStateShow) {
                if (weakSelfInters.kIntersCallbak) {
                    weakSelfInters.kIntersCallbak(kYD1InterstitialStateShow);
                }
            }else if (state == kYD1InterstitialStateClose) {
                if (weakSelfInters.kIntersCallbak) {
                    weakSelfInters.kIntersCallbak(kYD1InterstitialStateClose);
                }
                [weakSelfInters.kInterstitialView dismissViewControllerAnimated:YES
                                                                     completion:nil];
            }else if (state == kYD1InterstitialStateClicked) {
                if (weakSelfInters.kIntersCallbak) {
                    weakSelfInters.kIntersCallbak(kYD1InterstitialStateClicked);
                    weakSelfInters.kIntersCallbak(kYD1InterstitialStateClose);
                }
                [weakSelfInters.kInterstitialView dismissViewControllerAnimated:YES
                                                                     completion:nil];
            }
        });
    }];
    
    //Banner
     __weak Yodo1AdsManager *weakSelfBanner = self;
    [self.kBannerView setCallbak:^(YD1BannerState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (state == kYD1BannerStateClicked) {
                if (weakSelfBanner.kBannerCallbak) {
                    weakSelfBanner.kBannerCallbak(kYD1BannerStateClicked);
                }
            }else if (state == kYD1BannerStateShow){
                if (weakSelfBanner.kBannerCallbak) {
                    weakSelfBanner.kBannerCallbak(kYD1BannerStateShow);
                }
            }
        });
    }];
    
    __weak Yodo1AdsManager *weakSelfVideo = self;
    [self.kVideoViewController setCallbak:^(YD1VideoState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (state == kYD1VideoStateShow) {
                if (weakSelfVideo.kVideoCallbak) {
                    weakSelfVideo.kVideoCallbak(kYD1VideoStateShow);
                }
            }else if (state == kYD1VideoStateClose) {
                if (weakSelfVideo.kVideoCallbak) {
                    weakSelfVideo.kVideoCallbak(kYD1VideoStateClose);
                }
                [weakSelfVideo.kVideoViewController dismissViewControllerAnimated:YES
                                                                     completion:nil];
            }else if (state == kYD1VideoStateFinished){
                if (weakSelfVideo.kVideoCallbak) {
                    weakSelfVideo.kVideoCallbak(kYD1VideoStateFinished);
                }
            }
        });
    }];
}

#pragma mark- video

- (Yodo1VideoViewController*)kVideoViewController {
    if (_kVideoViewController == nil) {
        _kVideoViewController = [[Yodo1VideoViewController alloc]init];
        [_kVideoViewController configVideo];
    }
    return _kVideoViewController;
}

- (void)videoCallback:(YD1VideoCallback)callback {
    self.kVideoCallbak = [callback copy];
}

- (void)showVideo:(UIViewController *)viewController {
    
    if ([self.kVideoViewController isVideoReady]) {
        [self.kVideoViewController createVideoView:viewController];
        [self.kVideoViewController startProgressTimer];
        if (viewController) {
            [viewController presentViewController:self.kVideoViewController
                                         animated:YES
                                       completion:nil];
        }
        [self.kVideoViewController.videoPlayer seekTo:0.0f];
        [self.kVideoViewController.videoPlayer play];
    }else{
        if (self.kVideoCallbak) {
            self.kVideoCallbak(kYD1VideoStateFail);
        }
    }
}

- (BOOL)isVideoReady {
    if ([self.kVideoViewController isVideoReady]) {
        return YES;
    }
    return NO;
}

#pragma mark- Interstitial

- (Yodo1InterstitialViewController*)kInterstitialView {
    if (_kInterstitialView == nil) {
        _kInterstitialView = [[Yodo1InterstitialViewController alloc]init];
        [_kInterstitialView configInterstitial];
    }
    return _kInterstitialView;
}

- (BOOL)isInterstitialReady {
    return [self.kInterstitialView isInterstitialReady];
}

- (void)intersCallback:(YD1InterstitialCallback)callback {
    self.kIntersCallbak = [callback copy];
}

- (void)showInterstitial:(UIViewController *)viewController {
    
    if ([self isInterstitialReady]) {
        if (viewController) {
            [viewController presentViewController:self.kInterstitialView
                                         animated:YES
                                       completion:nil];
        }
        if (self.kIntersCallbak) {
            self.kIntersCallbak(kYD1InterstitialStateShow);
        }
    }else{
        if (self.kIntersCallbak) {
            self.kIntersCallbak(kYD1InterstitialStateFail);
        }
    }
}

#pragma mark- Banner

- (Yodo1BannerView*)kBannerView {
    if (_kBannerView == nil) {
        _kBannerView = [[Yodo1BannerView alloc]init];
    }
    return _kBannerView;
}

- (void)bannerCallback:(Yodo1BannerCallback)callback {
     self.kBannerCallbak = callback;
}

- (BOOL)isBannerReady {
    return [self.kBannerView isBannerReady];
}

- (UIView*)bannerView{
    return self.kBannerView;
}


@end
