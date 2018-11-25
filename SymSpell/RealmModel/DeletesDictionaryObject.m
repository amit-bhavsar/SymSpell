//
//  DeletesDictionaryObject.m
//  SymSpell-Realm
//
//  Created by Amit Bhavsar on 10/31/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "DeletesDictionaryObject.h"


@implementation DeletesDictionaryObject
+ (NSArray<NSString *> *)indexedProperties {
    return @[@"keyhash"];
}

+ (NSString *)primaryKey {
    return @"keyhash";
}



@end
