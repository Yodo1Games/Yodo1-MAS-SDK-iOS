//
//  AppDelegate.m
//  Yodo1MasSdkDemo
//
//  Created by ZhouYuzhen on 2020/11/24.
//

#import "AppDelegate.h"

#ifdef DEBUG
#import <DoraemonKit/DoraemonManager.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
        //默认
        [[DoraemonManager shareInstance] install];
        // 或者使用传入位置,解决遮挡关键区域,减少频繁移动
        //[[DoraemonManager shareInstance] installWithStartingPosition:CGPointMake(66, 66)];
#endif
    return YES;
}

@end
