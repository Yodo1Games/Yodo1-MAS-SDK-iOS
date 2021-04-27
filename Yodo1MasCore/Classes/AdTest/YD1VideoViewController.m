#import "YD1VideoViewController.h"
#import "YD1ImageHelp.h"
#import "UIView+YD1LayoutMethods.h"

NSString* const kVideoUrl = @"https://docs.yodo1.com/media/ad-test-resource/";

@interface YD1VideoViewController() <YD1VideoDelegate> {
    @private
    UITapGestureRecognizer *videoRecognizer;
    UIView* videoBackground;
    UIButton* closeBt;
    UILabel* countdown;
    UIView* videoEndPageViewBackground;
    __block UIImageView* endImageView;
    __block UIImage* _image;
    BOOL isClosed;
}

- (void)didClose;

- (void)endViewClose;

@end

@implementation YD1VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setFrame:[UIScreen mainScreen].bounds];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (void)configVideo {
    [YD1ImageHelp imageWithURL:[self imagePath] block:^(UIImage *image) {
        if (image) {
            self->_image = image;
        }else{
            NSLog(@"[ Yodo1 ] cached video of image return nil!");
        }
    }];
    if (_videoPlayer == nil) {
        _videoPlayer = [[YD1AVPlayer alloc]init];
    }
    _videoPlayer.delegate = self;
    [_videoPlayer prepare:[self videoPath] initialVolume:1 timeout:3000];
    if (_videoView == nil) {
        _videoView = [[YD1VideoView alloc] initWithFrame:self.view.frame];
    }
    [_videoView setVideoFillMode:AVLayerVideoGravityResize];
    [_videoView setPlayer:_videoPlayer];
}

- (BOOL)isLandscape {
    UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    return screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight;
}

- (NSString* )videoPath {
    NSString *path = [NSString stringWithFormat:@"%@ad-video-portrait.mp4",kVideoUrl];
    if ([self isLandscape]) {
        path = [NSString stringWithFormat:@"%@ad-video-landscape.mp4",kVideoUrl];
    }
    return path;
}

- (NSString* )imagePath {
    NSString* imageName = @"ad-video-landing-page-portrait.png";
    if ([self isLandscape]) {
        imageName = @"ad-video-landing-page-landscape.png";
    }
    NSString* path = [NSString stringWithFormat:@"%@%@",kVideoUrl,imageName];
    return path;
}

- (CGRect)getRect:(UIView *)view {
    CGFloat x = CGRectGetMinX(view.bounds);
    CGFloat y = CGRectGetMinY(view.bounds);
    CGFloat width = CGRectGetWidth(view.bounds);
    CGFloat height = CGRectGetHeight(view.bounds);
    return CGRectMake(x, y, width, height);
}

- (void)createVideoView:(UIViewController *)viewController {
    CGRect viewFrame = self.view.frame;
    videoBackground = [[UIView alloc]init];
    videoBackground.frame = viewFrame;
    videoBackground.backgroundColor = [UIColor clearColor];
    [videoBackground addSubview:self.videoView];
    
    countdown = [[UILabel alloc]init];
    [countdown setCt_size:CGSizeMake(44, 44)];
    countdown.text = [NSString stringWithFormat:@"%d",(int)self.videoPlayer.videoDuration/1000];
    countdown.textColor = [UIColor whiteColor];
    countdown.textAlignment = NSTextAlignmentCenter;
    [videoBackground addSubview: countdown];
    countdown.hidden = NO;
    countdown.backgroundColor = [UIColor clearColor];
    [self.view addSubview:videoBackground];
}

- (void)createVideoEndPageView {
    videoEndPageViewBackground = [[UIView alloc]init];
    videoEndPageViewBackground.frame = self.view.frame;
    videoEndPageViewBackground.backgroundColor = [UIColor whiteColor];
    [videoEndPageViewBackground setContentMode:UIViewContentModeScaleAspectFill];
    
    endImageView = [[UIImageView alloc]init];
    if (self->_image) {
        [endImageView setImage:self->_image];
    }else{
        [YD1ImageHelp imageWithURL:[self imagePath] block:^(UIImage *image) {
            if (image) {
                [self->endImageView setImage:image];
            }
        }];
    }
    
    [endImageView setContentMode:UIViewContentModeScaleAspectFill];
    endImageView.backgroundColor = [UIColor whiteColor];
    [endImageView setFrame:self.view.frame];
    endImageView.userInteractionEnabled = YES;
    [videoEndPageViewBackground addSubview:endImageView];
    
    closeBt = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBt addTarget:self action:@selector(endViewClose)
      forControlEvents:UIControlEventTouchUpInside];
    
    [closeBt setCt_size:CGSizeMake(44, 44)];
    [closeBt setTitle:@"Close" forState:UIControlStateNormal];
    [videoEndPageViewBackground addSubview:closeBt];
    
    videoRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                             action:@selector(bigMap:)];
    [endImageView addGestureRecognizer:videoRecognizer];
    videoRecognizer.numberOfTapsRequired = 1;
    
    [self.view addSubview:videoEndPageViewBackground];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    float w = CGRectGetWidth(self.view.frame);
    float h = CGRectGetHeight(self.view.frame);
    float ww = w;
    float hh = h;
    if ([self isLandscape]) {
        ww = w > h?w:h;
        hh = w > h?h:w;
    }else{
        ww = w > h?h:w;
        hh = w > h?w:h;
    }
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, ww, hh)];
    
    if (videoBackground) {
        [videoBackground setCt_size:CGSizeMake(ww, hh)];
        [videoBackground centerEqualToView:self.view];
        
        [_videoView setCt_size:CGSizeMake(ww, hh)];
        [_videoView centerEqualToView:videoBackground];
        
        [countdown relativeTopInContainer:(10.0f + closeBt.safeAreaTopGap)
                             shouldResize:NO
                               screenType:YD1UIScreenType_iPhone5];
        [countdown relativeRightInContainer:(10.0f + closeBt.safeAreaRightGap)
                               shouldResize:NO
                                 screenType:YD1UIScreenType_iPhone5];
    }
    
    if (videoEndPageViewBackground) {
        
        [videoEndPageViewBackground setCt_size:CGSizeMake(ww, hh)];
        [videoEndPageViewBackground centerEqualToView:self.view];
        [endImageView setCt_size:CGSizeMake(ww, hh)];
        [endImageView centerEqualToView:videoEndPageViewBackground];
        
        [closeBt relativeTopInContainer:(10.0f + closeBt.safeAreaTopGap)
                           shouldResize:NO
                             screenType:YD1UIScreenType_iPhone5];
        [closeBt relativeRightInContainer:(10.0f + closeBt.safeAreaRightGap)
                             shouldResize:NO
                               screenType:YD1UIScreenType_iPhone5];
    }
}

- (BOOL)isVideoReady {
    if (self.videoPlayer && [self.videoPlayer isReadyPlay] && self->_image) {
        return YES;
    }
    [YD1ImageHelp imageWithURL:[self imagePath]
                         block:^(UIImage *image) {
        if (image) {
            self->_image = image;
        }else{
            NSLog(@"[ Yodo1 ] cached video of image return nil!");
        }
    }];
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isClosed = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (@available(iOS 13.0, *)) {
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
          [self endViewClose];
      }
    }
    self.isShowing = NO;
}

- (void)yd1VideoDidLoaded {
    if (self.callbak) {
        self.callbak(kYD1VideoStateLoaded);
    }
}

- (void)yd1VideoDidFail:(NSError*)error {
    if (self.callbak) {
        self.callbak(kYD1VideoStateFail);
    }
}

- (void)yd1VideoDidStart {
    if (self.callbak) {
        self.callbak(kYD1VideoStateShow);
    }
}

- (void)yd1VideoDidPause {
}

- (void)yd1VideoDidStop {
    
}

- (void)yd1VideoDidFinish {
    [self didClose];
    [self stopProgressTimer];
    [self createVideoEndPageView];
    if (self.callbak) {
        self.callbak(kYD1VideoStateFinished);
    }
}

- (void)bigMap:(UITapGestureRecognizer*)tapRecognizer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yodo1.com"]];
}

- (void)endViewClose {
    if (isClosed) {
        return;
    }
    isClosed = YES;
    [endImageView removeGestureRecognizer:videoRecognizer];
    [videoEndPageViewBackground removeFromSuperview];
    videoEndPageViewBackground = nil;
    if (self.callbak) {
        self.callbak(kYD1VideoStateClose);
    }
}

- (void)videoProgressTimer:(NSTimer *)timer {
    countdown.hidden = NO;
    int progress = self.videoPlayer.videoDuration - (int)self.videoPlayer.getCurrentPosition;
    countdown.text = [NSString stringWithFormat:@"%d",progress/1000];
}

- (void)startProgressTimer {
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(videoProgressTimer:) userInfo:nil repeats:YES];
}

- (void)stopProgressTimer {
    countdown.hidden = YES;
    if (self.progressTimer && [self.progressTimer isKindOfClass:[NSTimer class]] && [self.progressTimer isValid]) {
        [self.progressTimer invalidate];
        self.progressTimer = NULL;
    }
}

- (void)didClose {
    [videoBackground removeFromSuperview];
    videoBackground = nil;
}

@end
