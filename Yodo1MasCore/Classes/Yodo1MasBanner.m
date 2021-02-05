//
//  Yodo1MasBanner.m
//  Yodo1MasCore
//
//  Created by 周玉震 on 2021/1/6.
//

#import "Yodo1MasBanner.h"
#import "Yodo1MasAdapterBase.h"

@implementation Yodo1MasBanner

+ (void)addBanner:(UIView *)banner tag:(NSInteger)tag controller:(UIViewController *)controller {
    UIView *contentView = [controller.view viewWithTag:tag];
    if (contentView == nil) {
        contentView = [[UIView alloc] initWithFrame:CGRectMake((controller.view.bounds.size.width - BANNER_SIZE_320_50.width) / 2, controller.view.bounds.size.height - BANNER_SIZE_320_50.height, BANNER_SIZE_320_50.width, BANNER_SIZE_320_50.height)];
        contentView.tag = tag;
        contentView.alpha = 0;
        [controller.view addSubview:contentView];
    }
    if (banner.superview != contentView) {
        if (banner.superview != nil) {
            [banner removeFromSuperview];
        }
        [contentView addSubview:banner];
    }
    banner.frame = contentView.bounds;
}

+ (void)showBannerWithTag:(NSInteger)tag controller:(UIViewController *)controller object:(NSDictionary *)object {
    UIView *contentView = [controller.view viewWithTag:tag];
    if (contentView != nil) {
        UIView *superview = contentView.superview;
        Yodo1MasAdBannerAlign align = Yodo1MasAdBannerAlignBottom | Yodo1MasAdBannerAlignHorizontalCenter;
        CGPoint offset = CGPointZero;
        if (object != nil) {
            if (object[kArgumentBannerAlign] != nil) {
                align = [object[kArgumentBannerAlign] integerValue];
            }
            
            if (object[kArgumentBannerOffset] != nil) {
                offset = [object[kArgumentBannerOffset] CGPointValue];
            }
        }
        
        CGRect frame = CGRectMake(0, 0, BANNER_SIZE_320_50.width, BANNER_SIZE_320_50.height);
        // horizontal
        if ((align & Yodo1MasAdBannerAlignLeft) == Yodo1MasAdBannerAlignLeft) {
            frame.origin.x = 0;
        } else if ((align & Yodo1MasAdBannerAlignRight) == Yodo1MasAdBannerAlignRight) {
            frame.origin.x = superview.bounds.size.width - frame.size.width;
        } else {
            frame.origin.x = (superview.bounds.size.width - frame.size.width) / 2;
        }
        
        // vertical
        if ((align & Yodo1MasAdBannerAlignTop) == Yodo1MasAdBannerAlignTop) {
            if (@available(iOS 11, *)) {
                frame.origin.y = superview.safeAreaInsets.top;
            } else {
                frame.origin.y = 0;
            }
        } else if ((align & Yodo1MasAdBannerAlignBottom) == Yodo1MasAdBannerAlignBottom) {
            
            if (@available(iOS 11, *)) {
                frame.origin.y = superview.bounds.size.height - frame.size.height - superview.safeAreaInsets.bottom;
            } else {
                frame.origin.y = superview.bounds.size.height - frame.size.height;
            }
        } else {
            frame.origin.y = (superview.bounds.size.height - frame.size.height) / 2;
        }
        
        frame.origin.x += offset.x;
        frame.origin.y += offset.y;
        
        contentView.frame = frame;
        contentView.alpha = 1;
    }
}

+ (void)removeBanner:(UIView *)banner tag:(NSInteger)tag destroy:(BOOL)destroy {
    UIViewController *controller = [Yodo1MasBanner viewController:banner];
    if (controller == nil) return;
    UIView *contentView = [controller.view viewWithTag:tag];
    if (contentView != nil) {
        if (destroy) {
            NSArray *subviews = [NSArray arrayWithArray:contentView.subviews];
            for (UIView *view in subviews) {
                [view removeFromSuperview];
            }
            [contentView removeFromSuperview];
        } else {
            contentView.alpha = 0;
        }
    }
}

+ (UIViewController *)viewController:(UIView *)banner {
    for (UIView *view = banner; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
