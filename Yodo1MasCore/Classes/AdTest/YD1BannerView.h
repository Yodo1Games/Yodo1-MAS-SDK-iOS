#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YD1AdvertConstant.h"


@interface YD1BannerView : UIView

@property (nonatomic,copy) YD1BannerCallback callbak;

- (BOOL)isBannerReady;

@end
