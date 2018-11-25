//
//  Entry.m
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "Entry.h"

@implementation Entry

- (id)initEntryWithCount:(int)count first:(int)first
{
    self = [super init];
    if (self) {
        _count = count;
        _first = first;
    }
    return self;
}

@end
