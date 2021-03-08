//
//  Yodo1Ads.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1Mas.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    Yodo1AdsEventClose          = 0,   //Close
    Yodo1AdsEventFinish         = 1,   //Finish playing
    Yodo1AdsEventClick          = 2,   //Click ad
    Yodo1AdsEventLoaded         = 3,   //Ad load finish
    Yodo1AdsEventShowSuccess    = 4,   //Display success
    Yodo1AdsEventShowFail       = 5,   //display fail
    Yodo1AdsEventSkip           = 6,   //skip
    Yodo1AdsEventLoadFail       = -1,  //Load of Error
} Yodo1AdsEvent;

typedef enum {
    Yodo1AdsBannerAdAlignLeft               = 1 << 0,
    Yodo1AdsBannerAdAlignHorizontalCenter   = 1 << 1,
    Yodo1AdsBannerAdAlignRight              = 1 << 2,
    Yodo1AdsBannerAdAlignTop                = 1 << 3,
    Yodo1AdsBannerAdAlignVerticalCenter     = 1 << 4,
    Yodo1AdsBannerAdAlignBottom             = 1 << 5,
} Yodo1AdsBannerAdAlign;

/**
 *  Yodo1AdsEvent call back
 *  @param adEvent Apecify the ad event.
 *  @param error ad event error.
 */
typedef void (^Yodo1AdsEventCallback)(Yodo1AdsEvent adEvent, NSError* error);
/**
*  Yodo1RewardGame call back
*  @param reward A JSONString of reward information.
*  @param error Reward game error.
*/
typedef void (^Yodo1RewardGameCallback)(NSString *reward, NSError* error);

@interface Yodo1Ads : NSObject

+ (NSString *)sdkVersion DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sdkVersion]");

//Init Yodo1Ads with appkey.
+ (void)initWithAppKey:(NSString *)appKey DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance] initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail");

#pragma mark- Banner
//Set banner's call back
+ (void)setBannerCallback:(Yodo1AdsEventCallback)callback DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].bannerAdDelegate");

//Set banner's align
+ (void)setBannerAlign:(Yodo1AdsBannerAdAlign)align DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showBannerAdWithAlign:]");

//Set banner's align,User-controlled viewcontroller
+ (void)setBannerAlign:(Yodo1AdsBannerAdAlign)align
        viewcontroller:(UIViewController*)viewcontroller DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showBannerAdWithAlign:]");

//Set banner's offset
+ (void)setBannerOffset:(CGPoint)point DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showBannerAdWithAlign:offset:]");

//Set the Banner Scale scaling factor x axis direction
//multiple sx,y axis direction multiple sy
+ (void)setBannerScale:(CGFloat)sx sy:(CGFloat)sy DEPRECATED_MSG_ATTRIBUTE("removed");

//Check if banner ad is ready to show
+ (BOOL)bannerIsReady DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] isBannerAdLoaded]");

//Show banner
+ (void)showBanner DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showBannerAd]");

+ (void)showBanner:(NSString *)placement_id DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showBannerAd:]");

//Hide banner
+ (void)hideBanner DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] dismissBannerAd]");

//Remove banner
+ (void)removeBanner DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] dismissBannerAd]");

#pragma mark- Interstitial

//Set interstitial's callback
+ (void)setInterstitialCallback:(Yodo1AdsEventCallback)callback DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].interstitialAdDelegate");

//Check if interstitial ad is ready to show
+ (BOOL)interstitialIsReady DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] isInterstitialAdLoaded]");

//Show interstitial
+ (void)showInterstitial DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showInterstitialAd]");
//Show interstitial with placement_id
+ (void)showInterstitialWithPlacement:(NSString *)placement_id DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showInterstitialAd:]");

//Show interstitial,User-controlled viewcontroller
+ (void)showInterstitial:(UIViewController*)viewcontroller DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showInterstitialAd]");
//Show interstitial,User-controlled viewcontroller with placement_id
+ (void)showInterstitial:(UIViewController *)viewcontroller placement:(NSString *)placement_id DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showInterstitialAd:]");

#pragma mark- Video

//Set video callback
+ (void)setVideoCallback:(Yodo1AdsEventCallback)callback DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].rewardAdDelegate");

//Check if video ad is ready to play
+ (BOOL)videoIsReady DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] isRewardAdLoaded]");

//Play video ad
+ (void)showVideo DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showRewardAd]");

+ (void)showVideoWithPlacement:(NSString *)placement_id;

//Play video ad,User-controlled viewcontroller
+ (void)showVideo:(UIViewController*)viewcontroller DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showRewardAd]");

+ (void)showVideo:(UIViewController *)viewcontroller placement:(NSString *)placement_id DEPRECATED_MSG_ATTRIBUTE("Please use [[Yodo1Mas sharedInstance] showRewardAd:]");

//This can be used by the integrating App to indicate if
//the user falls in any of the GDPR applicable countries
//(European Economic Area).
//consent YES User consents (Behavioral and Contextual Ads).
//NO if they are not.
+ (void)setUserConsent:(BOOL)consent DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].isGDPRUserConsent");

// return YES
// Agrees to collect data. The default is to collect data
+ (BOOL)isUserConsent DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].isGDPRUserConsent");

//In the US, the Children’s Online Privacy Protection Act (COPPA) imposes
//certain requirements on operators of online services that (a)
//have actual knowledge that the connected user is a child under 13 years of age,
//or (b) operate services (including apps) that are directed to children under 13.
//isBelowConsentAge YES if the user is affected by COPPA, NO if they are not.
+ (void)setTagForUnderAgeOfConsent:(BOOL)isBelowConsentAge DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].isCOPPAAgeRestricted");

// return YES It means
// under the age of 16
+ (BOOL)isTagForUnderAgeOfConsent DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].isCOPPAAgeRestricted");

//Set whether or not user has opted out of the sale of their personal information.
//doNotSell 'YES' if the user has opted out of the sale of their personal information.
+ (void)setDoNotSell:(BOOL)doNotSell DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].isCCPADoNotSell");

// return YES
// Indicates that the user has chosen not to
// sell their personal information
+ (BOOL)isDoNotSell DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1Mas sharedInstance].isCCPADoNotSell");

@end

NS_ASSUME_NONNULL_END
