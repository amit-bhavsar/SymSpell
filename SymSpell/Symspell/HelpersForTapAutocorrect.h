//
//  HelpersForTapAutocorrect.h
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/30/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpersForTapAutocorrect : NSObject

- (NSArray *)parseWords: (NSString *)phrase :(BOOL)preserveCase;
- (int)tryParseInst64: (NSString *)string;
- (BOOL)isAcronym: (NSString *)word;

@end

NS_ASSUME_NONNULL_END
