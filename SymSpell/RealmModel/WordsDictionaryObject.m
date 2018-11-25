//
//  WordsDictionaryObject.m
//  SymSpell-Realm
//
//  Created by Amit Bhavsar on 10/31/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "WordsDictionaryObject.h"


@implementation WordsDictionaryObject

+ (NSArray<NSString *> *)indexedProperties {
    return @[@"word"];
}

+(NSString *)primaryKey {
    return @"word";
}

@end
