#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YD1VideoDelegate <NSObject>

@optional

- (void)yd1VideoDidLoaded;

- (void)yd1VideoDidFail:(NSError*)error;

- (void)yd1VideoDidStart;

- (void)yd1VideoDidPause;

- (void)yd1VideoDidStop;

- (void)yd1VideoDidFinish;

@end

NS_ASSUME_NONNULL_END
