//
//  WordsDictionaryObject.h
//  SymSpell-Realm
//
//  Created by Amit Bhavsar on 10/31/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface WordsDictionaryObject : RLMObject

@property (nonatomic, strong) NSString *word;
@property long count;

@end

NS_ASSUME_NONNULL_END
