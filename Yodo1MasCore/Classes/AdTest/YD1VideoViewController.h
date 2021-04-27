#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YD1AdvertConstant.h"
#import "YD1VideoView.h"
#import "YD1AVPlayer.h"

@interface YD1VideoViewController : UIViewController
@property(nonatomic,assign) BOOL isShowing;

@property (nonatomic,copy) YD1VideoCallback callbak;
@property (nonatomic, strong) YD1AVPlayer *videoPlayer;
@property (nonatomic, strong) YD1VideoView *videoView;
@property (nonatomic, assign) id progressTimer;

- (void)configVideo;

- (BOOL)isVideoReady;

- (void)createVideoView:(UIViewController *)viewController;

- (void)createVideoEndPageView;
- (void)videoProgressTimer:(NSTimer *)timer;
- (void)startProgressTimer;
- (void)stopProgressTimer;

@end
