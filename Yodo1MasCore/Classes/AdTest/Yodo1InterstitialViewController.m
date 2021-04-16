#import "Yodo1InterstitialViewController.h"
#import "UIView+Yodo1LayoutMethods.h"
#import "Yodo1ImageHelp.h"

NSString* const kIntersUrl = @"https://docs.yodo1.com/media/ad-test-resource/";

@interface Yodo1InterstitialViewController() {
    UITapGestureRecognizer *recognizer;
    UIImageView *intersImageView;
    UIButton *closeBt;
    __block UIImage* _image;
    BOOL isClosed;
}

@end

@implementation Yodo1InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setFrame:[UIScreen mainScreen].bounds];
    intersImageView = [[UIImageView alloc]init];
    if (_image) {
        [intersImageView setImage:_image];
    }else{
        [Yodo1ImageHelp imageWithURL:self.path block:^(UIImage *image) {
            if (image) {
                self->_image = image;
                [self->intersImageView setImage:self->_image];
            }else{
                NSLog(@"[ Yodo1 ] cached inters of image return nil!");
            }
        }];
    }
    [intersImageView setContentMode:UIViewContentModeScaleAspectFill];
    intersImageView.backgroundColor = [UIColor grayColor];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [intersImageView setCt_size:CGSizeMake(600, 550)];
    }else {
        [intersImageView setCt_size:CGSizeMake(300, 275)];
    }
    intersImageView.userInteractionEnabled = YES;
    
    [self.view addSubview:intersImageView];
    
    closeBt = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBt addTarget:self action:@selector(endViewClose) forControlEvents:UIControlEventTouchUpInside];
    [closeBt setCt_size:CGSizeMake(44, 44)];
    [closeBt setTitle:@"Close" forState:UIControlStateNormal];
    
    [self.view addSubview:closeBt];
    
    recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bigMap:)];
    [intersImageView addGestureRecognizer:recognizer];
    recognizer.numberOfTapsRequired = 1;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (NSString *)path {
    if (_path == nil) {
        NSString* imageName = @"ad-interestital.png";
        UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        if (screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight) {
            imageName = @"ad-interestital.png";
        }
        _path = [NSString stringWithFormat:@"%@%@",kIntersUrl,imageName];
    }
    return _path;
}

- (void)configInterstitial {
     [Yodo1ImageHelp imageWithURL:self.path block:^(UIImage *image) {
        if (image) {
          self->_image = image;
        }else{
            NSLog(@"[ Yodo1 ] cached inters of image return nil!");
        }
    }];
}


- (BOOL)isLandscape {
    UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    return screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    float w = CGRectGetWidth(self.view.frame);
    float h = CGRectGetHeight(self.view.frame);
    float ww = w;
    float hh = h;
    if ([self isLandscape]) {
        ww = w > h?w:h;
        hh = w > h?h:w;
    }else{
        ww = w > h?h:w;
        hh = w > h?w:h;
    }
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, ww, hh)];
    
    [intersImageView centerEqualToView:self.view];
    [closeBt relativeTopInContainer:(10.0f + closeBt.safeAreaTopGap)
                       shouldResize:NO
                         screenType:YD1UIScreenType_iPhone5];
    [closeBt relativeRightInContainer:(10.0f + closeBt.safeAreaRightGap)
                         shouldResize:NO
                           screenType:YD1UIScreenType_iPhone5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isClosed = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (@available(iOS 13.0, *)) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
               [self endViewClose];
        }
    }
}

- (void)bigMap:(UITapGestureRecognizer*)tapRecognizer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yodo1.com"]];
    if (self.callbak) {
        self.callbak(kYD1InterstitialStateClicked);
    }
}

- (void)endViewClose {
    if (isClosed) {
        return;
    }
    isClosed = YES;
    if (self.callbak) {
        self.callbak(kYD1InterstitialStateClose);
    }
}

- (BOOL)isInterstitialReady {
    if (self->_image) {
        return YES;
    }
    [Yodo1ImageHelp imageWithURL:self.path block:^(UIImage *image) {
       if (image) {
         self->_image = image;
       }else{
           NSLog(@"[ Yodo1 ] cached inters of image return nil!");
       }
   }];
    return NO;
}

@end
