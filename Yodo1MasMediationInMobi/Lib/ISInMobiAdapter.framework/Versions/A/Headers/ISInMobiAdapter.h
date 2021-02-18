//
//  ISInMobiAdapter.h
//  ISInMobiAdapter
//
//  Created by Yotam Ohayon on 26/10/2015.
//  Copyright © 2015 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IronSource/ISBaseAdapter+Internal.h"

static NSString * const InMobiAdapterVersion = @"4.3.8";
static NSString * GitHash = @"89cd2cd22";
 
//System Frameworks For Inmobi Adapter

@import AdSupport;
@import AudioToolbox;
@import AVFoundation;
@import CoreTelephony;
@import CoreLocation;
@import Foundation;
@import MediaPlayer;
@import MessageUI;
@import StoreKit;
@import Social;
@import SystemConfiguration;
@import Security;
@import SafariServices;
@import UIKit;

@interface ISInMobiAdapter : ISBaseAdapter


@end
