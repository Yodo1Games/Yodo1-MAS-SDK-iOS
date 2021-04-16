#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Yodo1AdvertConstant.h"


@interface Yodo1BannerView : UIView

@property (nonatomic,copy) Yodo1BannerCallback callbak;

- (BOOL)isBannerReady;

@end
