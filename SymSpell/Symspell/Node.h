//
//  Node.h
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Node : NSObject

@property (nonatomic, retain) NSString * suggestion;
@property (nonatomic) int next;

-(id) initNodeWithSuggestion:(NSString *)suggestion next:(int)next;

@end

NS_ASSUME_NONNULL_END
