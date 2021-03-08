//
//  MoatPassiveVideoTracker.h
//  MoatMobileAppKit
//
//  Copyright © 2016 Moat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "INMMoatAdEvent.h"
#import "INMMoatBaseTracker.h"

typedef enum INMMoatTrackerState : NSUInteger {
    MTStateUninitialized
    , MTStateInitialized
    , MTStateTracking
    , MTStateDestroyed
} INMMoatTrackerState;

/** Tracker for tracking custom native video ads.
 *
 *  Unlike our standard video integration, which requires a reference to the player object and monitors playback
 * events automatically, this integration defines an API for you to dispatch the playback events to the Moat SDk and
 * does not require a reference to the player. This allows for a great degree of flexibility in the types of custom 
 * players we can support as long as you are able to dispatch the necessary events.
 *
 */
@interface INMMoatReactiveVideoTracker : INMMoatBaseTracker

@property (readonly) INMMoatTrackerState state;

/** Creates tracker for tracking video ads.
 *
 * Should be called before the ad is ready to play.
 *
 * @param partnerCode The code provided to you by Moat for video ad tracking.
 * @return INMMoatReactiveVideoTracker instance
 */
+ (INMMoatReactiveVideoTracker *)trackerWithPartnerCode:(NSString *)partnerCode;

/** Call to start tracking custom video ad.
 *
 * Should be called right before the ad is about to start playing.
 *
 * @param adIds information to identify and segment the ad
 * @param layer a reference to the ad's CALayer.
 * @param view the view that renders the video ad.
 * @param duration the length of the ad in milliseconds
 */
- (bool)trackVideoAd:(NSDictionary *)adIds
            withLayer:(CALayer *)layer
   withContainingView:(UIView *)view
   withDurationMillis:(NSTimeInterval) duration;

/** Call to report a video ad event.
 *
 * @see INMMoatAdEvent to see the required video ad events that must be reported to the SDK if they occur
 */
- (void)dispatchEvent:(INMMoatAdEvent *)event;

/** Call if the layer or view in which the video ad is rendered changes.
 *
 * @param newLayer the new parent layer of the player
 * @param view the new view tha renders the video ad.
 */
- (void)changeTargetLayer:(CALayer *)newLayer
        withContainingView:(UIView *)view;

/** Call to stop tracking the ad.
 *
 * Should be called at the completion of playback to ensure that all resources are disposed of properly.
 */
- (void)stopTracking;

@end
