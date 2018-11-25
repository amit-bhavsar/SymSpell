//
//  WeightedDistance.h
//  WeightedDistance
//
//  Created by Amit Bhavsar on 11/11/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Distance.h"
#import "KeyMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeightedDistance : NSObject

- (Distance *) GetWeightedDistanceBetweenUserWord:(NSString *)string1 andSystemWord:(NSString *)string2;

@end

NS_ASSUME_NONNULL_END
