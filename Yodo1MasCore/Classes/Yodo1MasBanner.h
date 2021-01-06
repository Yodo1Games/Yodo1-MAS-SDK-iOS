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

@interface Yodo1MasBanner : NSObject

+ (void)showBanner:(UIView *)banner controller:(UIViewController *)controller align:(Yodo1MasBannerAlign)align;
+ (void)removeBanner:(UIView *)banner;

@end

NS_ASSUME_NONNULL_END
