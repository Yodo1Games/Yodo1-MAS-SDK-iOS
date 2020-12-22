//
//  Yodo1MasResponse.h
//  Yodo1MasCore
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasResponse : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;

@end

NS_ASSUME_NONNULL_END
