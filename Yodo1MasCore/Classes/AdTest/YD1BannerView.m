#import "YD1BannerView.h"
#import "YD1ImageHelp.h"
#import "UIView+YD1LayoutMethods.h"


NSString* const kBannerUrl = @"https://docs.yodo1.com/media/ad-test-resource/";

@interface YD1BannerView() {
    UITapGestureRecognizer *bannerRecognizer;
    UIImageView *bannerImageView;
    __block UIImage* _image;
}

@property (nonatomic,strong)NSString* path;

@end

@implementation YD1BannerView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString* imageName = @"ad-banner1.png";
        UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        if (screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight) {
            imageName = @"ad-banner1.png";
        }
        _path = [NSString stringWithFormat:@"%@%@",kBannerUrl,imageName];
       
        self.backgroundColor = [UIColor grayColor];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self setFrame:CGRectMake(0, 0, 728, 90)];
        }else {
            [self setFrame:CGRectMake(0, 0, 320, 50)];
        }
        bannerImageView = [[UIImageView alloc]init];

        if (_image) {
             [bannerImageView setImage:_image];
         }else{
             [YD1ImageHelp imageWithURL:self.path block:^(UIImage *image) {
                 if (image) {
                     self->_image = image;
                     [self->bannerImageView setImage:self->_image];
                 }else{
                     NSLog(@"[ Yodo1 ] cached banner of image return nil!");
                 }
             }];
         }
        
        [bannerImageView setFrame:self.frame];
        bannerImageView.backgroundColor = [UIColor clearColor];
        bannerImageView.userInteractionEnabled = YES;
        [self addSubview:bannerImageView];
        
        bannerRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                  action:@selector(clickBanner:)];
        [bannerImageView addGestureRecognizer:bannerRecognizer];
        bannerRecognizer.numberOfTapsRequired = 1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [bannerImageView centerEqualToView:self];
}

- (void)clickBanner:(UITapGestureRecognizer*)tapRecognizer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yodo1.com"]];
    if (self.callbak) {
        self.callbak(kYD1BannerStateClicked);
    }
}

- (BOOL)isBannerReady {
    if (self->_image) {
        return YES;
    }
    [YD1ImageHelp imageWithURL:self.path block:^(UIImage *image) {
      if (image) {
          self->_image = image;
      }else{
          NSLog(@"[ Yodo1 ] cached banner of image return nil!");
      }
    }];
    return NO;
}

@end
