#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Yodo1AdvertConstant.h"
#import "Yodo1VideoView.h"
#import "Yodo1AVPlayer.h"

@interface Yodo1VideoViewController : UIViewController

@property (nonatomic,assign) BOOL isShowing;
@property (nonatomic,copy) YD1VideoCallback callbak;
@property (nonatomic, strong) Yodo1AVPlayer *videoPlayer;
@property (nonatomic, strong) Yodo1VideoView *videoView;
@property (nonatomic, assign) id progressTimer;

- (void)configVideo;

- (BOOL)isVideoReady;

- (void)createVideoView:(UIViewController *)viewController;

- (void)createVideoEndPageView;
- (void)videoProgressTimer:(NSTimer *)timer;
- (void)startProgressTimer;
- (void)stopProgressTimer;

@end
