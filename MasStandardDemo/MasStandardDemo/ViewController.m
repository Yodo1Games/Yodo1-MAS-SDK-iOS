//
//  ViewController.m
//  MasStandardDemo
//
//  Created by joyhubs on 2021/3/8.
//

#import "ViewController.h"
#import "Yodo1Mas.h"

@interface ViewController ()<Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Yodo1Mas sharedInstance].rewardAdDelegate = self;
    [Yodo1Mas sharedInstance].interstitialAdDelegate = self;
    [Yodo1Mas sharedInstance].bannerAdDelegate = self;
    

    [[Yodo1Mas sharedInstance] initWithAppId:@"qqiOsnhyOie" successful:^{
        
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)didShowVideo:(id)sender {
    
        [[Yodo1Mas sharedInstance] showRewardAd];
}

- (IBAction)didShowInters:(id)sender {
    
        [[Yodo1Mas sharedInstance] showInterstitialAd];
}
- (IBAction)didShowBanner:(id)sender {
    
        [[Yodo1Mas sharedInstance] showBannerAd];
}


#pragma mark - Yodo1MasAdDelegate
- (void)onAdOpened:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
    
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    if (error.code != Yodo1MasErrorCodeAdLoadFail) {
        NSLog(@"%@",[NSString stringWithFormat:@"Error: %@", error.userInfo[NSLocalizedDescriptionKey]]);
    }
}

#pragma mark - Yodo1MasRewardAdvertDelegate
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Earned" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
