
#import <AVFoundation/AVFoundation.h>
#import "Yodo1VideoDelegate.h"

@interface Yodo1AVPlayer : AVPlayer

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int progressInterval;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isReadyPlay;
@property (nonatomic, assign) id <Yodo1VideoDelegate>delegate;
@property (nonatomic, assign) float videoDuration;

- (void)setProgressEventInterval:(int)progressEventInterval;
- (void)prepare:(NSString *)url initialVolume:(float)volume timeout:(NSInteger)timeout;
- (void)stop;
- (void)stopObserving;
- (void)seekTo:(long)msec;
- (long)getCurrentPosition;

@end
