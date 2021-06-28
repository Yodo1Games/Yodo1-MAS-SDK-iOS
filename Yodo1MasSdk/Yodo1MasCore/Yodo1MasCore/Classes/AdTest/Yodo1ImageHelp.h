#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Yodo1ImageHelp : NSObject

+ (void)imageWithURL:(NSString *)url
               block:(void (^)(UIImage* image))block;

@end
