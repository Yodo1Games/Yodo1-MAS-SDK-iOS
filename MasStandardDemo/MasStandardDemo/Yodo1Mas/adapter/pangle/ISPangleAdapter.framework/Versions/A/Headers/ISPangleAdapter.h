//
//  ISPangleAdapter.h
//  ISPangleAdapter
//
//  Created by Guy Lis on 20/05/2019.
//  Copyright © 2019 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IronSource/ISBaseAdapter+Internal.h"

static NSString * const PangleAdapterVersion = @"4.3.3";
static NSString * GitHash = @"cb1090ae9";

//System Frameworks For Pangle Adapter

@import Accelerate;
@import AdSupport;
@import AudioToolbox;
@import AVFoundation;
@import CoreImage;
@import CoreLocation;
@import CoreMedia;
@import CoreMotion;
@import CoreTelephony;
@import ImageIO;
@import JavaScriptCore;
@import MapKit;
@import MediaPlayer;
@import MobileCoreServices;
@import Security;
@import StoreKit;
@import SystemConfiguration;
@import UIKit;
@import WebKit;


@interface ISPangleAdapter : ISBaseAdapter

@end
