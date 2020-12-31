//
//  MockViewController.h
//  Yodo1MasSdkDemo
//
//  Created by 周玉震 on 2020/12/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MockViewControllerDelegate <NSObject>

- (void)onMockSelected:(NSInteger)index;

@end

@interface MockViewController : UIViewController

@property(nonatomic, weak) id<MockViewControllerDelegate> delegate;

- (instancetype)initWithSourceView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
