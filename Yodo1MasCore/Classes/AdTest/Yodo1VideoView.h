#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Yodo1VideoView : UIView

@property (nonatomic) AVPlayer *player;

+ (Class)layerClass;
- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (AVPlayer*)player;

@end
