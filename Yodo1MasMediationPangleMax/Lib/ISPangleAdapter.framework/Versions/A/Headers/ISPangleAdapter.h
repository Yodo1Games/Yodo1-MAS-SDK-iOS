//
//  ISPangleAdapter.h
//  ISPangleAdapter
//
//  Created by Guy Lis on 20/05/2019.
//  Copyright © 2019 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IronSource/ISBaseAdapter+Internal.h"

static NSString * const PangleAdapterVersion = @"4.3.0";
static NSString * GitHash = @"98cdbc830";

//System Frameworks For Pangle Adapter

@import Accelerate;
@import AdSupport;
@import AVFoundation;
@import CoreLocation;
@import CoreMedia;
@import CoreMotion;
@import CoreTelephony;
@import MapKit;
@import MediaPlayer;
@import MobileCoreServices;
@import StoreKit;
@import SystemConfiguration;
@import UIKit;
@import WebKit;

@interface ISPangleAdapter : ISBaseAdapter

@end
