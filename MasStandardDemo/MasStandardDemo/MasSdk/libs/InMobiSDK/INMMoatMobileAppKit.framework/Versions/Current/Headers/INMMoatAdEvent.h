//
//  MoatAdEvent.h
//  MoatMobileAppKit
//
//  Created by Moat on 2/5/16.
//  Copyright © 2016 Moat. All rights reserved.
//
//  This class is simply a data object that encapsulates info relevant to a particular playback event.

#import <Foundation/Foundation.h>

typedef enum INMMoatAdEventType : NSUInteger {
    INMMoatAdEventComplete
    , INMMoatAdEventStart
    , INMMoatAdEventFirstQuartile
    , INMMoatAdEventMidPoint
    , INMMoatAdEventThirdQuartile
    , INMMoatAdEventSkipped
    , INMMoatAdEventStopped
    , INMMoatAdEventPaused
    , INMMoatAdEventPlaying
    , INMMoatAdEventVolumeChange
    , INMMoatAdEventNone
} INMMoatAdEventType;

static NSTimeInterval const INMMoatTimeUnavailable = NAN;
static float const INMMoatVolumeUnavailable = NAN;

@interface INMMoatAdEvent : NSObject

@property INMMoatAdEventType eventType;
@property NSTimeInterval adPlayhead;
@property float adVolume;
@property (readonly) NSTimeInterval timeStamp;

- (id)initWithType:(INMMoatAdEventType)eventType withPlayheadMillis:(NSTimeInterval)playhead;
- (id)initWithType:(INMMoatAdEventType)eventType withPlayheadMillis:(NSTimeInterval)playhead withVolume:(float)volume;
- (NSDictionary *)asDict;
- (NSString *)eventAsString;

@end
