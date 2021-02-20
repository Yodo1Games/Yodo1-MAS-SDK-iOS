//
//  ISFyberAdapter.h
//  ISFyberAdapter
//
//  Created by Gili Ariel on 14/03/2018.
//  Copyright © 2018 Gili Ariel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IronSource/ISBaseAdapter+Internal.h"

static NSString * const FyberAdapterVersion = @"4.3.13";
static NSString *  GitHash = @"66eabd769";

//System Frameworks For Fyber Adapter

@import AdSupport;
@import AVFoundation;
@import CoreGraphics;
@import CoreMedia;
@import CoreTelephony;
@import EventKit;
@import EventKitUI;
@import MediaPlayer;
@import MessageUI;
@import StoreKit;
@import SystemConfiguration;
@import WebKit;

@interface ISFyberAdapter : ISBaseAdapter

@end

