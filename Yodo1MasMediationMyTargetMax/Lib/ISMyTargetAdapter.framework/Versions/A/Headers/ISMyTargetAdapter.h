//
//  ISMyTargetAdapter.h
//  ISMyTargetAdapter
//
//  Created by Yonti Makmel on 12/01/2020.
//

#import <Foundation/Foundation.h>
#import "IronSource/ISBaseAdapter+Internal.h"

static NSString * const MyTargetAdapterVersion = @"4.1.6";
static NSString * GitHash = @"9f71d9bc3";

//System Frameworks For MyTarget Adapter
@import AdSupport;
@import AVFoundation;
@import CoreGraphics;
@import CoreMedia;
@import CoreTelephony;
@import StoreKit;
@import SystemConfiguration;


@interface ISMyTargetAdapter : ISBaseAdapter

@end
