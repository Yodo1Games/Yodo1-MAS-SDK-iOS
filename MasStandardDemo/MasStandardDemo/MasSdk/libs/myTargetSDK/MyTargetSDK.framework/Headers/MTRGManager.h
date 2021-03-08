//
//  MTRGManager.h
//  myTargetSDK 5.9.11
//
//  Created by Anton Bulankin on 18.09.15.
//  Copyright © 2015 Mail.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTRGManager : NSObject

+ (NSString *)getBidderToken; // this method should be called on background thread

@end

NS_ASSUME_NONNULL_END
