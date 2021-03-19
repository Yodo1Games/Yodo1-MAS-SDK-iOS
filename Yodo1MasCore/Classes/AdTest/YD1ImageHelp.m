#import "YD1ImageHelp.h"

@implementation YD1ImageHelp

+ (void)imageWithURL:(NSString *)url
               block:(void (^)(UIImage *))block {
   dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
   dispatch_async(globalQueue, ^{
       //NSString -> NSURL -> NSData -> UIImage
       NSURL *imageURL = [NSURL URLWithString:url];
       NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
       UIImage *image = [UIImage imageWithData:imageData];
       dispatch_async(dispatch_get_main_queue(), ^{
           if (block) {
               block(image);
           }
       });
   });
}

@end
