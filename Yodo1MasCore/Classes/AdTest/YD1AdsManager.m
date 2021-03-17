#import "YD1AdsManager.h"
#import "YD1InterstitialViewController.h"
#import "YD1BannerView.h"
#import "YD1VideoViewController.h"

@interface YD1AdsManager ()  {
    
    BOOL isInited;
}

@property (nonatomic, strong) YD1VideoCallback kVideoCallbak;
@property (nonatomic, strong) YD1InterstitialCallback kIntersCallbak;
@property (nonatomic, strong) YD1BannerCallback kBannerCallbak;

@property (nonatomic, strong) YD1InterstitialViewController *kInterstitialView;
@property (nonatomic, strong) YD1BannerView *kBannerView;
@property (nonatomic, strong) YD1VideoViewController *kVideoViewController;

- (BOOL)isLandscape;

@end

@implementation YD1AdsManager

static YD1AdsManager* _instance = nil;
+ (YD1AdsManager*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YD1AdsManager alloc]init];
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
    __weak YD1AdsManager *weakSelfInters = self;
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
     __weak YD1AdsManager *weakSelfBanner = self;
    [self.kBannerView setCallbak:^(YD1BannerState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (state == kYD1BannerStateClicked) {
                if (weakSelfBanner.kBannerCallbak) {
                    weakSelfBanner.kBannerCallbak(kYD1BannerStateClicked);
                }
            }
        });
    }];
    
    __weak YD1AdsManager *weakSelfVideo = self;
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

- (YD1VideoViewController*)kVideoViewController {
    if (_kVideoViewController == nil) {
        _kVideoViewController = [[YD1VideoViewController alloc]init];
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

- (YD1InterstitialViewController*)kInterstitialView {
    if (_kInterstitialView == nil) {
        _kInterstitialView = [[YD1InterstitialViewController alloc]init];
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

- (YD1BannerView*)kBannerView {
    if (_kBannerView == nil) {
        _kBannerView = [[YD1BannerView alloc]init];
    }
    return _kBannerView;
}

- (void)bannerCallback:(YD1BannerCallback)callback {
     self.kBannerCallbak = callback;
}

- (BOOL)isBannerReady {
    return [self.kBannerView isBannerReady];
}

- (UIView*)bannerView{
    return self.kBannerView;
}


@end
