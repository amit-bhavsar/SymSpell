//
//  TapAutoCorrect.h
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuggestItem.h"
#import "LevenshteinDistance.h"
#import "KeyMap.h"
#import "WeightedDistance.h"
#import <Realm/Realm.h>
#import "HelpersForTapAutocorrect.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapAutoCorrect : NSObject



@property(nonatomic) int initialCapacity;
@property(nonatomic) int maxDictionaryEditDistance;
@property(nonatomic) int prefixLength; //prefix length  5..7
@property(nonatomic) int countThreshold; //a treshold might be specifid, when a term occurs so frequently in the corpus that it is considered a valid word for spelling correction
@property(nonatomic) unsigned int compactMask;
@property(nonatomic) int maxLength; //maximum dictionary term length

@property(nonatomic, strong) KeyMap *keyMap;
@property(nonatomic, strong) NSMutableDictionary *deletes;
@property(nonatomic, strong) NSMutableDictionary *words;
@property(nonatomic, strong) NSMutableDictionary *belowThresholdWords;

@property(nonatomic, strong) NSMutableArray *suggestions;
@property(nonatomic, strong) NSString *phrase;
@property(nonatomic) int maxEditDistance;
@property(nonatomic) BOOL includeUnknown;
@property(nonatomic) BOOL verbosityTOP;
@property(nonatomic) BOOL verbosityCLOSEST;
@property(nonatomic) BOOL verbosityALL;
@property(nonatomic, strong) RLMRealm *realm;

@property(nonatomic, strong) LevenshteinDistance *levenshteinDistance;
@property(nonatomic, strong) WeightedDistance *weightedDistance;

- (void) initSymSpellWithCapacity:(int)initialCapacity MaxDictionaryEditDistance:(int)maxDictionaryEditDistance PrefixLength:(int)prefixLength CountTHreshold:(int)countThreshold compactLevel:(int)compactLevel maxLength:(int)maxLength;

- (BOOL) loadDictionaryWithStirng;

- (NSMutableArray *) lookupForWord:(NSString *)phrase maxEditDistance:(int)maxEditDistance verbosity:(int)verbose includeUnknown:(BOOL)includeUnknown;
- (NSMutableArray *) lookupRealmForWord:(NSString *)phrase maxEditDistance:(int)maxEditDistance verbosity:(int)verbose includeUnknown:(BOOL)includeUnknown;

- (NSMutableArray *) lookupCompoundForWord:(NSString *)phrase maxEditDistance:(int)maxEditDistance ingnoreNonWords:(BOOL)ingnoreNonWords;
@end

NS_ASSUME_NONNULL_END

