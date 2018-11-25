//
//  SuggestItem.m
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/22/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "SuggestItem.h"

@implementation SuggestItem

- (id)initSuggestItem: (NSString *)t :(NSInteger)d :(NSInteger)c{
    
    self = [super init];
    if (self) {
        self.term = t;
        self.distance = d;
        self.count = c;
    }
    return self;
}

- (BOOL) eq: (SuggestItem *)other{
    if (self.distance == other.distance){
        return self.count == other.count;
    }else{
        return self.distance = other.distance;
    }
}

- (BOOL)lt: (SuggestItem *)other{
    if (self.distance == other.distance){
        return self.count > other.count;
    }else{
        return self.distance < other.distance;
    }
}

-(SuggestItem *)returnSuggestItem{
    return self;
}

@end
