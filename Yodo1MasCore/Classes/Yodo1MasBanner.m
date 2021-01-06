//
//  Yodo1MasBanner.m
//  Yodo1MasCore
//
//  Created by 周玉震 on 2021/1/6.
//

#import "Yodo1MasBanner.h"
#import "Yodo1MasAdapterBase.h"

@implementation Yodo1MasBanner

+ (void)showBanner:(UIView *)banner controller:(UIViewController *)controller align:(Yodo1MasBannerAlign)align {
    UIView *superview = controller != nil? controller.view : [Yodo1MasAdapterBase getTopWindow];
    if (superview != nil && banner != nil) {
        CGRect frame = CGRectMake(0, 0, 320, 50);
        // horizontal
        if ((align & Yodo1MasBannerAlignLeft) == Yodo1MasBannerAlignLeft) {
            frame.origin.x = 0;
        } else if ((align & Yodo1MasBannerAlignRight) == Yodo1MasBannerAlignRight) {
            frame.origin.x = superview.bounds.size.width - frame.size.width;
        } else {
            frame.origin.x = (superview.bounds.size.width - frame.size.width) / 2;
        }
        
        // vertical
        if ((align & Yodo1MasBannerAlignTop) == Yodo1MasBannerAlignTop) {
            if (@available(iOS 11, *)) {
                frame.origin.y = superview.safeAreaInsets.top;
            } else {
                frame.origin.y = 0;
            }
        } else if ((align & Yodo1MasBannerAlignBottom) == Yodo1MasBannerAlignBottom) {
            
            if (@available(iOS 11, *)) {
                frame.origin.y = superview.bounds.size.height - frame.size.height - superview.safeAreaInsets.bottom;
            } else {
                frame.origin.y = superview.bounds.size.height - frame.size.height;
            }
        } else {
            frame.origin.y = (superview.bounds.size.height - frame.size.height) / 2;
        }
        
        banner.frame = frame;
        [superview addSubview:banner];
    }
}

+ (void)removeBanner:(UIView *)banner {
    if (banner != nil) [banner removeFromSuperview];
}

@end
