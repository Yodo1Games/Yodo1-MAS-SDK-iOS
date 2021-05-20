//
//  Yodo1LuckyWheelHelper.h
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Yodo1MasLuckyWheelInitializeDelegate <NSObject>
@optional

///Called after initialize successful
- (void)onSuccess:(BOOL)available;

/// Called after initialization fails
- (void)onFailure:(NSError *)error;

@end

@protocol Yodo1MasLuckyWheelRewardDelegate <NSObject>
@optional

///Called after an RewardGame has attempted to show but failed.
- (void)onDisplayFailure:(NSString *)error;

///Called after an RewardGame has been rewarded.
- (void)onRewardEarned:(NSString *)reward;

@end

@interface Yodo1LuckyWheelHelper : NSObject

+ (Yodo1LuckyWheelHelper *)shared;
@property(nonatomic,copy) NSString * appKey;
@property(nonatomic,copy) NSString * webUrl;
@property(nonatomic,assign) BOOL activitySwitch;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (void)initWithAppKey:(NSString *)appKey
              delegate:(id<Yodo1MasLuckyWheelInitializeDelegate>)delegate;

- (void)show:(UIViewController *)viewcontroller
    delegate:(id<Yodo1MasLuckyWheelRewardDelegate>)delegate;

- (void)rewardGameReward:(NSDictionary *)para
                response:(void(^)(NSDictionary * rewardData))response;

- (NSString *)signMd5String:(NSString *)origString;

- (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error;

- (NSString *)language;

@end

NS_ASSUME_NONNULL_END
