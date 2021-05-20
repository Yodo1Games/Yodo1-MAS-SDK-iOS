//
//  Yodo1LuckyWheelViewController.h
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1LuckyWheelHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1LuckyWheelViewController : UIViewController

+ (void)show:(UIViewController *)viewController
    delegate:(id<Yodo1MasLuckyWheelRewardDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
