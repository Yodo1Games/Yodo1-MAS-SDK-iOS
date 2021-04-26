#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Yodo1AdvertConstant.h"


@interface Yodo1InterstitialViewController : UIViewController


@property (nonatomic,copy) YODO1InterstitialCallback callbak;
@property(nonatomic,strong)NSString* path;

- (void)configInterstitial;

- (BOOL)isInterstitialReady;

@end
