//
//  Yodo1MasBanner.m
//  Yodo1MasCore
//
//  Created by 周玉震 on 2021/1/6.
//

#import "Yodo1MasBanner.h"
#import "Yodo1MasAdapterBase.h"

@implementation Yodo1MasBanner

- (void)showBanner:(UIView *)banner controller:(UIViewController *)controller align:(Yodo1MasBannerAlign)align {
    UIView *superview = controller != nil? controller.view : [Yodo1MasAdapterBase getTopWindow];
    if (superview != nil) {
        CGRect frame = CGRectMake(0, 0, 320, 50);
        
    }
}

- (void)removeBanner:(UIView *)banner {
    if (banner != nil) [banner removeFromSuperview];
}

@end
