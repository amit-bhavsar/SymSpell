//
//  ChunkyArray.m
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "ChunkyArray.h"
#import "Node.h"

@implementation ChunkyArray

const int chunkSize = 4096;
const int divShift = 12;

- (id)initWithCapacity:(int)initialCapacity
{
    self = [super init];
    if (self) {
        
        //NSUInteger chunks = (initialCapacity + chunkSize - 1) / chunkSize;
        _values = [@[ [@[] mutableCopy] , [@[] mutableCopy] ] mutableCopy];
        
    }
    return self;
}

- (int) add: (Node *)value{
    
    if (_count == [self capacity]){
        
    }
    return _count - 1;
}

- (int)capacity{
    return (int)[_values count] * chunkSize;
}

@end
