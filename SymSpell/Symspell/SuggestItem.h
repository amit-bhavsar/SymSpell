//
//  SuggestItem.h
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/22/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SuggestItem : NSObject{
    
}

@property (nonatomic, strong) NSString *term;
@property (nonatomic) NSInteger distance;
@property (nonatomic) NSInteger count;

//public methods

- (id)initSuggestItem: (NSString *)t :(NSInteger)d :(NSInteger)c;

@end

NS_ASSUME_NONNULL_END
