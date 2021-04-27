#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YD1AdvertConstant.h"


@interface YD1InterstitialViewController : UIViewController
@property(nonatomic,assign) BOOL isShowing;

@property (nonatomic,copy) YD1InterstitialCallback callbak;
@property(nonatomic,strong)NSString* path;

- (void)configInterstitial;

- (BOOL)isInterstitialReady;

@end
