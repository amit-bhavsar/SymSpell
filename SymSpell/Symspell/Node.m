//
//  Node.m
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "Node.h"

@implementation Node

-(id) initNodeWithSuggestion:(NSString *)suggestion next:(int)next
{
    self = [super init];
    if (self) {
        _suggestion = suggestion;
        _next = next;
    }
    return self;
}

@end
