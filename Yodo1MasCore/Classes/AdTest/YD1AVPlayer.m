
#import "YD1AVPlayer.h"

@interface YD1AVPlayer ()
    @property (nonatomic, strong) NSTimer* progressTimer;
    @property (nonatomic, strong) NSTimer* prepareTimeoutTimer;
    @property (nonatomic, assign) BOOL isObservingCompletion;
@end

@implementation YD1AVPlayer

static void *kYD1PlaybackLikelyToKeepUpKVOToken = &kYD1PlaybackLikelyToKeepUpKVOToken;
static void *kYD1PlaybackBufferEmpty = &kYD1PlaybackBufferEmpty;
static void *kYD1PlaybackBufferFull = &kYD1PlaybackBufferFull;
static void *kYD1ItemStatusChangeToken = &kYD1ItemStatusChangeToken;

- (void)prepare:(NSString *)url initialVolume:(float)volume timeout:(NSInteger)timeout {
    [self stopObserving];
    self.url = url;
    NSURL *videoURL = [NSURL URLWithString:self.url];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSInteger adjustedTimeout = timeout / 1000;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressInterval = 1000;
        [self setVolume:volume];
        [self replaceCurrentItemWithPlayerItem:playerItem];
        [self startObserving];
        [self startPrepareTimeoutTimer:adjustedTimeout];
    });
}

- (void)startObserving {
    if (self.currentItem) {
        @try {
            [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:kYD1ItemStatusChangeToken];
        }
        @catch (id exception) {
            NSLog(@"Failed adding observer for 'status'");
        }

        @try {
            [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:kYD1PlaybackBufferEmpty];
        }
        @catch (id exception) {
            NSLog(@"Failed adding observer for 'playbackBufferEmpty'");
        }
        
        @try {
            [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:kYD1PlaybackLikelyToKeepUpKVOToken];
        }
        @catch (id exception) {
            NSLog(@"Failed adding observer for 'playbackLikelyToKeepUp'");
        }
        
        @try {
            [self.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:0 context:kYD1PlaybackBufferFull];
        }
        @catch (id exception) {
            NSLog(@"Failed adding observer for 'playbackBufferFull'");
        }
    }
}

- (void)stopObserving {
    NSLog(@"Attempting to remove observers for item: %@", self.url);
    if (self.currentItem) {
        @try {
            [self.currentItem removeObserver:self forKeyPath:@"status" context:kYD1ItemStatusChangeToken];
        }
        @catch (id exception) {
            NSLog(@"Failed removing observer for 'status'");
        }
        
        @try {
            [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:kYD1PlaybackBufferEmpty];
        }
        @catch (id exception) {
            NSLog(@"Failed removing observer for 'playbackBufferEmpty'");
        }

        @try {
            [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:kYD1PlaybackLikelyToKeepUpKVOToken];
        }
        @catch (id exception) {
            NSLog(@"Failed removing observer for 'playbackLikelyToKeepUp'");
        }

        @try {
            [self.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:kYD1PlaybackBufferFull];
        }
        @catch (id exception) {
            NSLog(@"Failed removing observer for 'playbackBufferFull'");
        }

    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.isObservingCompletion = false;
}

- (void)setProgressEventInterval:(int)progressEventInterval {
    if (self.progressInterval != progressEventInterval) {
        [self stopVideoProgressTimer];
        self.progressInterval = progressEventInterval;
        [self startVideoProgressTimer];
    }
}

- (void)startPrepareTimeoutTimer:(NSInteger)timeout {
    if (_prepareTimeoutTimer == nil) {
        _prepareTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(onPrepareTimeoutListener:) userInfo:nil repeats:false];
    }
}

- (void)stopPrepareTimeoutTimer {
    if (_prepareTimeoutTimer && [_prepareTimeoutTimer isValid]) {
        [_prepareTimeoutTimer invalidate];
        _prepareTimeoutTimer = NULL;
    }
}

- (void)onPrepareTimeoutListener:(NSNotification *)notification {
}

- (void)onCompletionListener:(NSNotification *)notification {
    self.isPlaying = false;
    [self stopVideoProgressTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(yd1VideoDidFinish)]) {
            [self.delegate yd1VideoDidFinish];
        }
    });
}

- (void)startVideoProgressTimer {
    float interval = (float)self.progressInterval / 1000;
    if (_progressTimer == nil) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(videoProgressTimer:) userInfo:nil repeats:YES];
    }
}

- (void)stopVideoProgressTimer {
    if (_progressTimer && [_progressTimer isValid]) {
        [_progressTimer invalidate];
        _progressTimer = NULL;
    }
}

- (void)videoProgressTimer:(NSTimer *)timer {
   
}

- (void)play {
    if (!self.isObservingCompletion) {
        self.isObservingCompletion = true;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCompletionListener:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    }

    [super play];
    self.isPlaying = true;
    [self stopVideoProgressTimer];
    [self startVideoProgressTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(yd1VideoDidStart)]) {
            [self.delegate yd1VideoDidStart];
        }
    });
}

- (void)pause {
    [super pause];
    self.isPlaying = false;
    [self stopVideoProgressTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(yd1VideoDidPause)]) {
            [self.delegate yd1VideoDidPause];
        }
    });
}

- (void)stop {
    [super pause];
    self.isPlaying = false;
    [self stopVideoProgressTimer];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(yd1VideoDidStop)]) {
            [self.delegate yd1VideoDidStop];
        }
    });
}

- (void)seekTo:(long)msec {
    Float64 t_ms = msec / 1000;
    CMTime time = CMTimeMakeWithSeconds(t_ms, 30);
    [self seekToTime:time completionHandler:^(BOOL finished) {}];
}

- (long)getMsFromCMTime:(CMTime)time {
    Float64 current = CMTimeGetSeconds(time);
    Float64 ms = current * 1000;
    return (long)ms;
}

- (long)getCurrentPosition {
    return [self getMsFromCMTime:self.currentTime];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kYD1ItemStatusChangeToken) {
        AVPlayerItemStatus playerItemStatus = self.currentItem.status;
        if (playerItemStatus == AVPlayerItemStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *tracks = [self.currentItem.asset tracksWithMediaType:AVMediaTypeVideo];

                float width = -1;
                float height = -1;
                if ([tracks count] > 0) {
                    AVAssetTrack *track = [tracks objectAtIndex:0];
                    CGSize mediaSize = track.naturalSize;
                    width = mediaSize.width;
                    height = mediaSize.height;
                }
                self.videoDuration = [self getMsFromCMTime:self.currentItem.duration];
                
                if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(yd1VideoDidLoaded)]) {
                    [self.delegate yd1VideoDidLoaded];
                }
                
            });
            self.isReadyPlay = YES;
            [self stopPrepareTimeoutTimer];
        }
        else if (playerItemStatus == AVPlayerItemStatusFailed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate != nil &&[self.delegate respondsToSelector:@selector(yd1VideoDidFail:)]) {
                    [self.delegate yd1VideoDidFail:self.currentItem.error];
                }
            });
            self.isReadyPlay = NO;
            [self stopPrepareTimeoutTimer];
        }
    }
    else if (context == kYD1PlaybackLikelyToKeepUpKVOToken) {
        
    }
    else if (context == kYD1PlaybackBufferEmpty) {
        
    }
    else if (context == kYD1PlaybackBufferFull) {
       
    }
}

@end
