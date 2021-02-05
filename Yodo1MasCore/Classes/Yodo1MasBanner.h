//
//  Yodo1MasBanner.h
//  Yodo1MasCore
//
//  Created by 周玉震 on 2021/1/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1MasCommon.h"

NS_ASSUME_NONNULL_BEGIN

#define BANNER_SIZE_320_50  CGSizeMake(320, 50)

@interface Yodo1MasBanner : NSObject

+ (void)addBanner:(UIView *)banner tag:(NSInteger)tag controller:(UIViewController *)controller;
+ (void)showBannerWithTag:(NSInteger)tag controller:(UIViewController *)controller object:(NSDictionary *)object;
+ (void)removeBanner:(UIView *)banner tag:(NSInteger)tag destroy:(BOOL)destroy;

@end

NS_ASSUME_NONNULL_END
