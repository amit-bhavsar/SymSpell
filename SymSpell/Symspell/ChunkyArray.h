//
//  ChunkyArray.h
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChunkyArray : NSObject

@property (nonatomic) int count;
@property (nonatomic) NSMutableArray *values;



- (id)initWithCapacity:(int)initialCapacity;

@end

NS_ASSUME_NONNULL_END
