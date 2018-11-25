//
//  TapAutoCorrect.m
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/25/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "TapAutoCorrect.h"
#import "WordsDictionaryObject.h"
#import "DeletesDictionaryObject.h"

@implementation TapAutoCorrect
@synthesize realm;

const int defaultMaxEditDistance = 2;
const int defaultPrefixLength = 7;
const int defaultCountThreshold = 1;
const int defaultInitialCapacity = 16;
const int defaultCompactLevel = 5;

- (void) initSymSpellWithCapacity:(int)initialCapacity MaxDictionaryEditDistance:(int)maxDictionaryEditDistance PrefixLength:(int)prefixLength CountTHreshold:(int)countThreshold compactLevel:(int)compactLevel maxLength:(int)maxLength{


    _initialCapacity = initialCapacity;
    _maxDictionaryEditDistance = maxDictionaryEditDistance;
    _prefixLength = prefixLength;
    _countThreshold = countThreshold;
    _maxLength = maxLength;
    if (compactLevel > 16) compactLevel = 16;
    _compactMask = (0xFFFFFFFF >> (3 + MIN(compactLevel, 16))) << 2;
    _words = [[NSMutableDictionary alloc]init];
    _belowThresholdWords = [[NSMutableDictionary alloc]init];
    _deletes = [[NSMutableDictionary alloc]init];
    _keyMap = [[KeyMap alloc]init];

    if (realm == nil) {
        [self loadRealm];
    }
}

- (void) loadRealm {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];

    // Get the URL to the bundled file
    config.fileURL = [[NSBundle mainBundle] URLForResource:@"Dictionary" withExtension:@"realm"];
    // Open the file in read-only mode as application bundles are not writeable
    config.readOnly = YES;

    [RLMRealmConfiguration setDefaultConfiguration:config];
    // Open the Realm with the configuration
    //self.realm = [RLMRealm realmWithConfiguration:config error:nil];


    //    RLMResults<DeleteWord *> *deleteWords = [DeleteWord allObjects];
    //    NSLog(@"%@",deleteWords);

    //    Word *word = [[Word Word:@"key == fully"] firstObject];
    //
    //    NSLog(@"Key : %@, value: %@", word.key, word.value);

    //[self callSymspell];
}

- (BOOL) loadDictionaryWithStirng{

    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSASCIIStringEncoding error:&error];

    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);

    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];

    for(int i=0; i<[listArray count]; i++){
        if([[listArray objectAtIndex:i] length]>0){
            NSArray* singleStrs =
            [[listArray objectAtIndex:i] componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@" "]];
            NSString *key = [singleStrs objectAtIndex:0];

            long count = (long)[[singleStrs objectAtIndex:1] integerValue];
            if (!(key == nil)){
                [self createDictionaryEntryWithKey:key frequency:count];
            }
        }
    }

    NSLog(@"words: %@",[_words objectForKey:@"this"]);
    NSLog(@"deletes: %lu",_deletes.count);

    
    [self insertWordInRealm:_words];
    [self insertDeleteWordInRealm:_deletes];

    NSURL* documentURL =   [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSURL* pathURL = [documentURL URLByAppendingPathComponent:@"Dictionary.realm"];

    NSLog(@"URL: %@",pathURL);

    [realm writeCopyToURL:pathURL encryptionKey:nil error:nil];

    NSLog(@"REALM PROCESS DONE");
    
    //NSLog(@"below threshold: %lu",_belowThresholdWords.count);

    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
     NSString *documentsDir = [paths objectAtIndex:0];
     NSLog(@"%@", documentsDir);

     [_words writeToFile:[documentsDir stringByAppendingPathComponent:@"words.plist"] atomically:YES];
     [_deletes writeToFile:[documentsDir stringByAppendingPathComponent:@"deletes.plist"] atomically:YES];*/

    return 0;

}

- (void) insertWordInRealm: (NSDictionary*) wordDict {

    NSMutableArray *words = [[NSMutableArray alloc]init];
    for (NSString* key in wordDict.allKeys) {

        WordsDictionaryObject *word = [[WordsDictionaryObject alloc]init];
        word.word = key;
        word.count = [wordDict[key] longValue];
        [words addObject:word];

//        [_realm transactionWithBlock:^{
//            [self.realm addObject:word];
//        }];
    }

    [realm transactionWithBlock:^{
        [self.realm addObjects:words];
    }];
}

- (void) insertDeleteWordInRealm: (NSDictionary*) delteWordDict {

    NSMutableArray *deleteWords = [[NSMutableArray alloc]init];
    for (id key in delteWordDict.allKeys) {

        DeletesDictionaryObject *deleteWord = [[DeletesDictionaryObject alloc]init];
        NSString *keyhash = [NSString stringWithFormat:@"%@",key];
        deleteWord.keyhash = keyhash;
        NSMutableArray *words = (NSMutableArray*)delteWordDict[key];
        for (NSString *word in words) {
            [deleteWord.deletedWords addObject:word];
        }

        [deleteWords addObject:deleteWord];

//        [_realm transactionWithBlock:^{
//            [self.realm addObject:deleteWord];
//        }];
    }

    [realm transactionWithBlock:^{
        [self.realm addObjects:deleteWords];
    }];



    //    DeleteWord *deleteWord = [[DeleteWord alloc]init];
    //    deleteWord.keyhash = keyHash;
    //
    //    for (NSString *word in words) {
    //        [deleteWord.words addObject:word];
    //    }
    //
    //    [_realm transactionWithBlock:^{
    //        [self.realm addObject:deleteWord];
    //    }];
}

- (void) addAllInRealm {

}

- (BOOL) createDictionaryEntryWithKey: (NSString *)key frequency:(long)count{

    /*Create/Update an entry in the dictionary.
     For every word there are deletes with an edit distance of
     1..max_edit_distance created and added to the dictionary. Every delete
     entry has a suggestions list, which points to the original term(s) it
     was created from. The dictionary may be dynamically updated (word
     frequency and new words) at any time by calling create_dictionary_entry

     Keyword arguments:
     key -- The word to add to dictionary.
     count -- The frequency count for word.

     Return:
     True if the word was added as a new correctly spelled word, or
     False if the word is added as a below threshold word, or updates an
     existing correctly spelled word.*/

    if (count <= 0){
        //no point doing anything if count is zero, as it can't change anything
        if (_countThreshold > 0){
            return false;
        }
        count = 0;
    }

    // look first in below threshold words, update count, and allow
    // promotion to correct spelling word if count reaches threshold
    // threshold must be >1 for there to be the possibility of low threshold
    // words

    if (_countThreshold > 1 && _belowThresholdWords[key]){

        long countPrevious = (long)[_belowThresholdWords valueForKey:key];

        // calculate new count for below threshold word



        if ((LONG_MAX - countPrevious) > count){
            count = countPrevious + count;
        }else{
            count = (long)LONG_MAX;
        }

        // has reached threshold - remove from below threshold collection
        // (it will be added to correct words below)

        if (count > _countThreshold){

            [_belowThresholdWords removeObjectForKey:key];

        }else{

            [_belowThresholdWords setObject:[NSNumber numberWithLong:count] forKey:key];
            return false;

        }

    }else if (_words[key]){

        long countPrevious = (long)[_words valueForKey:key];

        // just update count if it's an already added above threshold word

        if ((LONG_MAX - countPrevious) > count){
            count = countPrevious + count;
        }else{
            count = (long)LONG_MAX;
        }

        [_words setObject:[NSNumber numberWithLong:count] forKey:key];

        return false;

    }else if (count < _countThreshold){

        // new or existing below threshold word
        [_belowThresholdWords setObject:[NSNumber numberWithLong:count] forKey:key];

        return false;

    }

    // what we have at this point is a new, above threshold word

    [_words setObject:[NSNumber numberWithLong:count] forKey:key];

    /*edits/suggestions are created only once, no matter how often word occurs.
     edits/suggestions are created as soon as the word occurs in the corpus, even
     if the same term existed before in the dictionary as an edit from another word*/

    if (key.length > _maxLength){
        _maxLength = (int)key.length;
    }

    // create deletes

    NSSet *edits = [self editsPrefixWithKey:key];

    for (NSString *delete in edits){


        long delete_hash = [self gethashForString:delete];
        NSMutableArray *array = [[NSMutableArray alloc]init];

        if ([_deletes objectForKey:[NSNumber numberWithLong:delete_hash]]){
            array = [_deletes objectForKey:[NSNumber numberWithLong:delete_hash]];
            if (![array containsObject:key]){
                [array addObject:key];
            }
        }else{
            [array addObject:key];
        }

        [_deletes setObject:array forKey:[NSNumber numberWithLong:delete_hash]];

    }

    NSString *firstLetterMap = [_keyMap MapStringSameRow:[key characterAtIndex:0]];
    
    for (int i = 0; i < firstLetterMap.length; i++){
        
        int64_t delete_hash = [self gethashForString:[NSString stringWithFormat:@"%c",[firstLetterMap characterAtIndex:i]]];
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        if ([_deletes objectForKey:[NSNumber numberWithLongLong:delete_hash]]){
            array = [_deletes objectForKey:[NSNumber numberWithLongLong:delete_hash]];
            if (![array containsObject:key]){
                [array addObject:key];
            }
        }else{
            [array addObject:key];
        }
        
        
        [_deletes setObject:array forKey:[NSNumber numberWithLongLong:delete_hash]];
        
    }
    
    NSString *lastLetterMap = [_keyMap MapStringSameRow:[key characterAtIndex:key.length-1]];
    
    if (key.length > 1){
        for (int i = 0; i < lastLetterMap.length; i++){
            
            int64_t delete_hash = [self gethashForString:[NSString stringWithFormat:@"%c",[lastLetterMap characterAtIndex:i]]];
            NSMutableArray *array = [[NSMutableArray alloc]init];
            
            if ([_deletes objectForKey:[NSNumber numberWithLongLong:delete_hash]]){
                array = [_deletes objectForKey:[NSNumber numberWithLongLong:delete_hash]];
                if (![array containsObject:key]){
                    [array addObject:key];
                }
            }else{
                [array addObject:key];
            }
            
            
            [_deletes setObject:array forKey:[NSNumber numberWithLongLong:delete_hash]];
            
        }
    }
    
    return true;

}

- (NSMutableSet *)editWord:(NSString *)word editDistance:(int)editDistance deleteWords:(NSMutableSet *)deleteWords{

    editDistance += 1;

    if (word.length > 1){

        for (int i = 0; i < word.length; i++) {

            NSString *delete = [word stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@""];

            if (![deleteWords containsObject:delete]){

                [deleteWords addObject:delete];

                // recursion, if maximum edit distance not yet reached
                if (editDistance < _maxDictionaryEditDistance){

                    [self editWord:delete editDistance:editDistance deleteWords:deleteWords];

                }
            }
        }
    }

    return deleteWords;
}

- (NSMutableSet *)editsPrefixWithKey:(NSString *)key{

    NSMutableSet *hashSet = [[NSMutableSet alloc]init];

    if (key.length <= _maxDictionaryEditDistance){
        [hashSet addObject:@""];
    }

    if (key.length > _maxDictionaryEditDistance && key.length > _prefixLength){
        key = [key substringWithRange:NSMakeRange(0, _prefixLength)];
    }

    [hashSet addObject:key];

    return [self editWord:key editDistance:0 deleteWords:hashSet];

}

/*
- (NSString *) gethashForString:(NSString *)s{
    
    int s_length = (int)s.length;
    int mask_len = MIN(s_length, 3);
    
    int64_t hash_s = 2166136261;
    
    for (int i = 0; i < s_length; i++){
        hash_s ^= [s characterAtIndex:i];
        hash_s *= 16777619;
    }
    
    hash_s &= _compactMask;
    hash_s |= mask_len;
    
    return [NSString stringWithFormat:@"%lli", hash_s];
    
}*/

- (long) gethashForString:(NSString *)s{
    
    int s_length = (int)s.length;
    int mask_len = MIN(s_length, 3);
    
    long hash_s = 2166136261;
    
    for (int i = 0; i < s_length; i++){
        hash_s ^= [s characterAtIndex:i];
        hash_s *= 16777619;
    }
    
    hash_s &= _compactMask;
    hash_s |= mask_len;
    
    return hash_s;
    
}


- (NSMutableArray *) lookupRealmForWord:(NSString *)phrase maxEditDistance:(int)maxEditDistance verbosity:(int)verbose includeUnknown:(BOOL)includeUnknown{

    /*Find suggested spellings for a given phrase word.

     Keyword arguments:
     phrase -- The word being spell checked.
     verbosity -- The value controlling the quantity/closeness of the
     returned suggestions.

     # Top suggestion with the highest term frequency of the suggestions of
     # smallest edit distance found.
     TOP = 0
     # All suggestions of smallest edit distance found, suggestions ordered by
     # term frequency.
     CLOSEST = 1
     # All suggestions within maxEditDistance, suggestions ordered by edit
     # distance, then by term frequency (slower, no early termination).
     ALL = 2

     max_edit_distance -- The maximum edit distance between phrase and
     suggested words.
     include_unknown -- Include phrase word in suggestions, if no words
     within edit distance found.

     Return:
     A list of SuggestItem object representing suggested correct spellings
     for the phrase word, sorted by edit distance, and secondarily by count
     frequency*/

    if (!maxEditDistance) maxEditDistance = _maxDictionaryEditDistance;
    if (maxEditDistance > _maxDictionaryEditDistance) maxEditDistance = _maxDictionaryEditDistance;

    _maxEditDistance = maxEditDistance;
    _phrase = phrase;
    _suggestions = [[NSMutableArray alloc]init];
    _includeUnknown = includeUnknown;
    [self setVerbosity:verbose];
    int phraseLen = (int)_phrase.length;

    // early exit - word is too big to possibly match any words
    _maxLength = 28;//max length of all words static
    if (phraseLen - _maxEditDistance > _maxLength){
        return [self earlyExit];
    }

    //quick look for exact match

    long suggestionCount = 0;

//    NSString *query = [NSString stringWithFormat:@"word = '%@'",phrase];
//    RLMResults<WordsDictionaryObject *> *wordsTemp = [WordsDictionaryObject objectsInRealm:realm where:query];
    WordsDictionaryObject *wordObj = [WordsDictionaryObject objectForPrimaryKey:phrase];
    
    if (wordObj) {
        suggestionCount = wordObj.count;
        [_suggestions addObject: [[SuggestItem alloc]initSuggestItem:_phrase :0 :suggestionCount]];

        if (!_verbosityALL){
            return [self earlyExit];
        }
    }


    // early termination, if we only want to check if word in dictionary or
    // get its frequency e.g. for word segmentation

    if (maxEditDistance == 0) {
        return [self earlyExit];
    }

    NSMutableSet *consideredDeletes = [[NSMutableSet alloc]init];
    NSMutableSet *consideredSuggestions = [[NSMutableSet alloc]init];

    // we considered the phrase already in the 'phrase in self._words' above

    [consideredSuggestions addObject:_phrase];
    int maxEditDistance2 = _maxEditDistance;

    int candidatePointer = 0;

    NSMutableArray *candidates = [[NSMutableArray alloc]init];

    // add original prefix

    int phrasePrefixLength = phraseLen;

    if (phrasePrefixLength > _prefixLength){

        phrasePrefixLength = _prefixLength;
        [candidates addObject:[_phrase substringToIndex:phrasePrefixLength]];

    }else{
        [candidates addObject:_phrase];
    }

    _levenshteinDistance = [[LevenshteinDistance alloc]init];
    _weightedDistance = [[WeightedDistance alloc]init];

    while (candidatePointer < candidates.count) {
        NSString *candidate = [candidates objectAtIndex:candidatePointer];
        candidatePointer += 1;
        int candidateLength = (int)candidate.length;
        int lenDiff = phrasePrefixLength - candidateLength;

        // early termination: if candidate distance is already higher than
        // suggestin distance, than there are no better suggestions to be
        // expected

        if (lenDiff > maxEditDistance2){

            // skip to next candidate if Verbosity.ALL, look no
            // further if Verbosity.TOP or CLOSEST (candidates are
            // ordered by delete distance, so none are closer than current)

            if (_verbosityALL){
                continue;
            }

            break;

        }

//        NSString *queryDelete = [NSString stringWithFormat:@"keyhash = %ld",[self gethashForString:candidate]];
//        RLMResults<DeletesDictionaryObject *> *deleteWordsTemp = [DeletesDictionaryObject objectsInRealm:realm where:queryDelete];
        
        NSString *hashString = [NSString stringWithFormat:@"%li", [self gethashForString:candidate]];
        DeletesDictionaryObject *deleteObj = [DeletesDictionaryObject objectForPrimaryKey:hashString];

        if (deleteObj) {
            for (NSString *suggestion in deleteObj.deletedWords) {
                if ([suggestion isEqualToString:_phrase]){
                    break;
                }

                int suggestionLen = (int)suggestion.length;

                // phrase and suggestion lengths diff > allowed/current best distance

                if (abs(suggestionLen-phraseLen) > maxEditDistance2 ||
                    // suggestion must be for a different delete string, in same bin only because of hash collision
                    suggestionLen < candidateLength ||
                    // if suggestion len = delete len, then it either equals delete or is in same bin only because of hash collision
                    (suggestionLen == candidateLength && ![suggestion isEqualToString:candidate])){

                    break;

                }

                int suggestionPrefixLen = MIN(suggestionLen, _prefixLength);

                if (suggestionPrefixLen > phrasePrefixLength &&
                    suggestionPrefixLen - candidateLength > maxEditDistance2){

                    break;

                }

                // True Damerau-Levenshtein Edit Distance: adjust distance,
                // if both distances>0
                // We allow simultaneous edits (deletes) of max_edit_distance
                // on on both the dictionary and the phrase term.
                // For replaces and adjacent transposes the resulting edit
                // distance stays <= max_edit_distance.
                // For inserts and deletes the resulting edit distance might
                // exceed max_edit_distance.
                // To prevent suggestions of a higher edit distance, we need
                // to calculate the resulting edit distance, if there are
                // simultaneous edits on both sides.
                // Example: (bank==bnak and bank==bink, but bank!=kanb and
                // bank!=xban and bank!=baxn for max_edit_distance=1)
                // Two deletes on each side of a pair makes them all equal,
                // but the first two pairs have edit distance=1, the others
                // edit distance=2.


                int distance = 0;
                int minDistance = 0;

                if (candidateLength == 0){

                    // suggestions which have no common chars with phrase
                    // (phrase_len<=max_edit_distance &&
                    // suggestion_len<=max_edit_distance)

                    distance = MAX(phraseLen, suggestionLen);

                    if (distance > maxEditDistance2 || [consideredSuggestions containsObject:suggestion]){
                        break;
                    }

                }

                else if (suggestionLen == 1){

                    if ([_phrase rangeOfString:[NSString stringWithFormat:@"%c",[suggestion characterAtIndex:0]]].location < 0){
                        distance = phraseLen;
                    }else{
                        distance = phraseLen - 1;
                    }

                    if (distance > maxEditDistance2 || [consideredSuggestions containsObject:suggestion]){
                        break;
                    }
                }

                // number of edits in prefix ==maxediddistance AND no
                // identical suffix, then editdistance>max_edit_distance and
                // no need for Levenshtein calculation
                // (phraseLen >= prefixLength) &&
                // (suggestionLen >= prefixLength)
                else{

                    // handles the shortcircuit of min_distance assignment
                    // when first boolean expression evaluates to False

                    if (_prefixLength - maxEditDistance == candidateLength){

                        minDistance = (MIN(phraseLen, suggestionLen) - _prefixLength);

                    }else {
                        minDistance = 0;
                    }

                    if ((_prefixLength - maxEditDistance == candidateLength) &&
                        ((((minDistance > 1) && !([[_phrase substringFromIndex:phraseLen + 1 - minDistance] isEqualToString:[suggestion substringFromIndex:suggestionLen + 1 - minDistance]]))) ||((minDistance > 0) && !([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen - minDistance]] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:suggestionLen - minDistance]]]) && (!([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen - minDistance - 1]] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:suggestionLen - minDistance]]]) || !([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen - minDistance]] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:suggestionLen - minDistance - 1]]]))))){

                        /*if (((_prefixLength - maxEditDistance == candidateLength)
                         && ((minDistance > 1) && (![[_phrase substringFromIndex:phraseLen + 1 - minDistance] isEqualToString:[suggestion substringFromIndex:suggestionLen + 1 - minDistance]])))
                         || ((minDistance > 0) && !([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen-minDistance]] isEqualToString:[NSString stringWithFormat:@"%c",[suggestion characterAtIndex: suggestionLen-minDistance]]]) && (!([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen-minDistance-1]] isEqualToString:[NSString stringWithFormat:@"%c",[suggestion characterAtIndex: suggestionLen-minDistance-1]]])))){*/

                        break;

                    }else{

                        // delete_in_suggestion_prefix is somewhat expensive,
                        // and only pays off when verbosity is TOP or CLOSEST

                        if ((!_verbosityALL && ![self deleteInSuggestionPrefix:candidate :candidateLength :suggestion :suggestionLen]) || [consideredSuggestions containsObject:suggestion]){

                            break;

                        }

                        [consideredSuggestions addObject:suggestion];

                        distance = [_levenshteinDistance getLevenshteinDistance:_phrase :suggestion :maxEditDistance2];

                        if (distance < 0){
                            break;
                        }

                    }

                }

                // do not process higher distances than those already found,
                // if verbosity<ALL (note: max_edit_distance_2 will always
                // equal max_edit_distance when Verbosity.ALL)

                if (distance <= maxEditDistance2){

//                    NSString *query = [NSString stringWithFormat:@"word = '%@'",suggestion];
//                    RLMResults<WordsDictionaryObject *> *wordsTempDelete = [WordsDictionaryObject objectsInRealm:realm where:query];

                    WordsDictionaryObject *wordObj = [WordsDictionaryObject objectForPrimaryKey:suggestion];
                    
                    suggestionCount = wordObj.count;

                    SuggestItem *si = [[SuggestItem alloc]initSuggestItem:suggestion :distance :suggestionCount];

                    if(_suggestions.count > 0){

                        if(_verbosityCLOSEST){

                            // we will calculate DamLev distance only to the smallest found distance so far

                            if (distance < maxEditDistance2){
                                _suggestions = [[NSMutableArray alloc]init];
                            }

                        }else if (_verbosityTOP){

                            SuggestItem *temp = [_suggestions objectAtIndex:0];
                            if (distance < maxEditDistance2 || suggestionCount > temp.count){

                                maxEditDistance2 = distance;
                                [_suggestions replaceObjectAtIndex:0 withObject:si];

                            }

                            break;
                        }
                    }

                    if (!_verbosityALL){
                        maxEditDistance2 = distance;
                    }

                    [_suggestions addObject:si];
                }

            }

        }


        // add edits: derive edits (deletes) from candidate (phrase) and add them to candidates list. this is a recursive process until the maximum edit distance has been reached

        if (lenDiff < maxEditDistance && candidateLength <= _prefixLength){

            // do not create edits with edit distance smaller than suggestions already found

            if (!_verbosityALL && lenDiff >= maxEditDistance2){
                break;
            }

            for (int i = 0; i < candidateLength; i++){

                NSString *delete = [candidate stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@""];

                if (![consideredDeletes containsObject:delete]){

                    [consideredDeletes addObject:delete];
                    [candidates addObject:delete];
                }
            }
        }
    }

    return [[self sortedSuggestionList:_suggestions] mutableCopy];
}

- (NSMutableArray *) lookupForWord:(NSString *)phrase maxEditDistance:(int)maxEditDistance verbosity:(int)verbose includeUnknown:(BOOL)includeUnknown{

    /*Find suggested spellings for a given phrase word.

     Keyword arguments:
     phrase -- The word being spell checked.
     verbosity -- The value controlling the quantity/closeness of the
     returned suggestions.

     # Top suggestion with the highest term frequency of the suggestions of
     # smallest edit distance found.
     TOP = 0
     # All suggestions of smallest edit distance found, suggestions ordered by
     # term frequency.
     CLOSEST = 1
     # All suggestions within maxEditDistance, suggestions ordered by edit
     # distance, then by term frequency (slower, no early termination).
     ALL = 2

     max_edit_distance -- The maximum edit distance between phrase and
     suggested words.
     include_unknown -- Include phrase word in suggestions, if no words
     within edit distance found.

     Return:
     A list of SuggestItem object representing suggested correct spellings
     for the phrase word, sorted by edit distance, and secondarily by count
     frequency*/

    if (!maxEditDistance) maxEditDistance = _maxDictionaryEditDistance;
    if (maxEditDistance > _maxDictionaryEditDistance) maxEditDistance = _maxDictionaryEditDistance;

    _maxEditDistance = maxEditDistance;
    _phrase = phrase;
    _suggestions = [[NSMutableArray alloc]init];
    _includeUnknown = includeUnknown;
    [self setVerbosity:verbose];
    int phraseLen = (int)_phrase.length;

    // early exit - word is too big to possibly match any words
    if (phraseLen - _maxEditDistance > _maxLength){
        return [self earlyExit];
    }

    //quick look for exact match

    int64_t suggestionCount = 0;

    if (_words[phrase]){
        suggestionCount = [[_words objectForKey:phrase] longLongValue];
        [_suggestions addObject: [[SuggestItem alloc]initSuggestItem:_phrase :0 :suggestionCount]];
        if (!_verbosityALL){
            return [self earlyExit];
        }
    }

    // early termination, if we only want to check if word in dictionary or
    // get its frequency e.g. for word segmentation

    if (maxEditDistance == 0) {
        return [self earlyExit];
    }

    NSMutableSet *consideredDeletes = [[NSMutableSet alloc]init];
    NSMutableSet *consideredSuggestions = [[NSMutableSet alloc]init];

    // we considered the phrase already in the 'phrase in self._words' above

    [consideredSuggestions addObject:_phrase];
    int maxEditDistance2 = _maxEditDistance;

    int candidatePointer = 0;

    NSMutableArray *candidates = [[NSMutableArray alloc]init];

    // add original prefix

    int phrasePrefixLength = phraseLen;

    if (phrasePrefixLength > _prefixLength){

        phrasePrefixLength = _prefixLength;
        [candidates addObject:[_phrase substringToIndex:phrasePrefixLength]];

    }else{
        [candidates addObject:_phrase];
    }

    _levenshteinDistance = [[LevenshteinDistance alloc]init];

    while (candidatePointer < candidates.count) {
        NSString *candidate = [candidates objectAtIndex:candidatePointer];
        candidatePointer += 1;
        int candidateLength = (int)candidate.length;
        int lenDiff = phrasePrefixLength - candidateLength;

        // early termination: if candidate distance is already higher than
        // suggestin distance, than there are no better suggestions to be
        // expected

        if (lenDiff > maxEditDistance2){

            // skip to next candidate if Verbosity.ALL, look no
            // further if Verbosity.TOP or CLOSEST (candidates are
            // ordered by delete distance, so none are closer than current)

            if (_verbosityALL){
                continue;
            }

            break;

        }

        //if ([[_deletes allKeys] containsObject:[NSNumber numberWithLong:[self gethashForString:candidate]]]){
        if ([_deletes objectForKey:[NSNumber numberWithLong:[self gethashForString:candidate]]]){
            NSArray *dictSuggestions = [_deletes objectForKey:[NSNumber numberWithLong:[self gethashForString:candidate]]];

            for (NSString *suggestion in dictSuggestions){
                if ([suggestion isEqualToString:_phrase]){
                    break;
                }

                int suggestionLen = (int)suggestion.length;

                // phrase and suggestion lengths diff > allowed/current best distance

                if (abs(suggestionLen-phraseLen) > maxEditDistance2 ||
                    // suggestion must be for a different delete string, in same bin only because of hash collision
                    suggestionLen < candidateLength ||
                    // if suggestion len = delete len, then it either equals delete or is in same bin only because of hash collision
                    (suggestionLen == candidateLength && ![suggestion isEqualToString:candidate])){

                    break;

                }

                int suggestionPrefixLen = MIN(suggestionLen, _prefixLength);

                if (suggestionPrefixLen > phrasePrefixLength &&
                    suggestionPrefixLen - candidateLength > maxEditDistance2){

                    break;

                }

                // True Damerau-Levenshtein Edit Distance: adjust distance,
                // if both distances>0
                // We allow simultaneous edits (deletes) of max_edit_distance
                // on on both the dictionary and the phrase term.
                // For replaces and adjacent transposes the resulting edit
                // distance stays <= max_edit_distance.
                // For inserts and deletes the resulting edit distance might
                // exceed max_edit_distance.
                // To prevent suggestions of a higher edit distance, we need
                // to calculate the resulting edit distance, if there are
                // simultaneous edits on both sides.
                // Example: (bank==bnak and bank==bink, but bank!=kanb and
                // bank!=xban and bank!=baxn for max_edit_distance=1)
                // Two deletes on each side of a pair makes them all equal,
                // but the first two pairs have edit distance=1, the others
                // edit distance=2.


                int distance = 0;
                int minDistance = 0;

                if (candidateLength == 0){

                    // suggestions which have no common chars with phrase
                    // (phrase_len<=max_edit_distance &&
                    // suggestion_len<=max_edit_distance)

                    distance = MAX(phraseLen, suggestionLen);

                    if (distance > maxEditDistance2 || [consideredSuggestions containsObject:suggestion]){
                        break;
                    }

                }

                else if (suggestionLen == 1){

                    if ([_phrase rangeOfString:[NSString stringWithFormat:@"%c",[suggestion characterAtIndex:0]]].location < 0){
                        distance = phraseLen;
                    }else{
                        distance = phraseLen - 1;
                    }

                    if (distance > maxEditDistance2 || [consideredSuggestions containsObject:suggestion]){
                        break;
                    }
                }

                // number of edits in prefix ==maxediddistance AND no
                // identical suffix, then editdistance>max_edit_distance and
                // no need for Levenshtein calculation
                // (phraseLen >= prefixLength) &&
                // (suggestionLen >= prefixLength)
                else{

                    // handles the shortcircuit of min_distance assignment
                    // when first boolean expression evaluates to False

                    if (_prefixLength - maxEditDistance == candidateLength){

                        minDistance = (MIN(phraseLen, suggestionLen) - _prefixLength);

                    }else {
                        minDistance = 0;
                    }

                    if ((_prefixLength - maxEditDistance == candidateLength) &&
                        ((((minDistance > 1) && !([[_phrase substringFromIndex:phraseLen + 1 - minDistance] isEqualToString:[suggestion substringFromIndex:suggestionLen + 1 - minDistance]]))) ||((minDistance > 0) && !([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen - minDistance]] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:suggestionLen - minDistance]]]) && (!([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen - minDistance - 1]] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:suggestionLen - minDistance]]]) || !([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen - minDistance]] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:suggestionLen - minDistance - 1]]]))))){

                        /*if (((_prefixLength - maxEditDistance == candidateLength)
                         && ((minDistance > 1) && (![[_phrase substringFromIndex:phraseLen + 1 - minDistance] isEqualToString:[suggestion substringFromIndex:suggestionLen + 1 - minDistance]])))
                         || ((minDistance > 0) && !([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen-minDistance]] isEqualToString:[NSString stringWithFormat:@"%c",[suggestion characterAtIndex: suggestionLen-minDistance]]]) && (!([[NSString stringWithFormat:@"%c", [_phrase characterAtIndex:phraseLen-minDistance-1]] isEqualToString:[NSString stringWithFormat:@"%c",[suggestion characterAtIndex: suggestionLen-minDistance-1]]])))){*/

                        break;

                    }else{

                        // delete_in_suggestion_prefix is somewhat expensive,
                        // and only pays off when verbosity is TOP or CLOSEST

                        if ((!_verbosityALL && ![self deleteInSuggestionPrefix:candidate :candidateLength :suggestion :suggestionLen]) || [consideredSuggestions containsObject:suggestion]){

                            break;

                        }

                        [consideredSuggestions addObject:suggestion];

                        distance = [_levenshteinDistance getLevenshteinDistance:_phrase :suggestion :maxEditDistance2];

                        if (distance < 0){
                            break;
                        }

                    }

                }

                // do not process higher distances than those already found,
                // if verbosity<ALL (note: max_edit_distance_2 will always
                // equal max_edit_distance when Verbosity.ALL)

                if (distance <= maxEditDistance2){
                    suggestionCount = [[_words objectForKey:suggestion] longLongValue];

                    SuggestItem *si = [[SuggestItem alloc]initSuggestItem:suggestion :distance :suggestionCount];

                    if(_suggestions.count > 0){

                        if(_verbosityCLOSEST){

                            // we will calculate DamLev distance only to the smallest found distance so far

                            if (distance < maxEditDistance2){
                                _suggestions = [[NSMutableArray alloc]init];
                            }

                        }else if (_verbosityTOP){

                            SuggestItem *temp = [_suggestions objectAtIndex:0];
                            if (distance < maxEditDistance2 || suggestionCount > temp.count){

                                maxEditDistance2 = distance;
                                [_suggestions replaceObjectAtIndex:0 withObject:si];

                            }

                            break;
                        }
                    }

                    if (!_verbosityALL){
                        maxEditDistance2 = distance;
                    }

                    [_suggestions addObject:si];
                }

            }

        }

        // add edits: derive edits (deletes) from candidate (phrase) and add them to candidates list. this is a recursive process until the maximum edit distance has been reached

        if (lenDiff < maxEditDistance && candidateLength <= _prefixLength){

            // do not create edits with edit distance smaller than suggestions already found

            if (!_verbosityALL && lenDiff >= maxEditDistance2){
                break;
            }

            for (int i = 0; i < candidateLength; i++){

                NSString *delete = [candidate stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@""];

                if (![consideredDeletes containsObject:delete]){

                    [consideredDeletes addObject:delete];
                    [candidates addObject:delete];
                }
            }
        }
    }

    return [[self sortedSuggestionList:_suggestions] mutableCopy];
}

- (NSMutableArray *) lookupCompoundForWord:(NSString *)phrase maxEditDistance:(int)maxEditDistance ingnoreNonWords:(BOOL)ingnoreNonWords{
    
    /*lookup_compound supports compound aware automatic spelling
     correction of multi-word input strings with three cases:
     1. mistakenly inserted space into a correct word led to two incorrect
     terms
     2. mistakenly omitted space between two correct words led to one
     incorrect combined term
     3. multiple independent input terms with/without spelling errors
     
     Find suggested spellings for a multi-word input string (supports word
     splitting/merging).
     
     Keyword arguments:
     phrase -- The string being spell checked.
     max_edit_distance -- The maximum edit distance between input and
     suggested words.
     
     Return:
     A List of SuggestItem object representing suggested correct spellings
     for the input string.
     */
    
    // Parse input string into single terms
    
    HelpersForTapAutocorrect *helpers = [[HelpersForTapAutocorrect alloc]init];
    
    NSArray<NSString *> *termList1 = [helpers parseWords:phrase :NO];
    
    // Second list of single terms with preserved cases so we can ignore
    // acronyms (all cap words)
    
    NSArray<NSString*> *termList2;
    
    if (ingnoreNonWords){
        termList2 = [helpers parseWords:phrase :YES];
    }
    
    NSMutableArray<SuggestItem*> *suggestions = [[NSMutableArray alloc]init];
    NSMutableArray *suggestion_parts = [[NSMutableArray alloc]init];
    LevenshteinDistance *distanceComparer = [[LevenshteinDistance alloc]init];
    
    // translate every item to its best suggestion, otherwise it remains unchanged
    
    BOOL isLastCombi = false;
    
    for (int i = 0 ; i < [termList1 count]; i++){
        
        if (ingnoreNonWords){
            
            if ([helpers tryParseInst64:[termList1 objectAtIndex:i]] > 0){
                
                [suggestion_parts addObject:[[SuggestItem alloc]initSuggestItem:[termList1 objectAtIndex:i] :0 :0]];
                continue;
                
            }
            
            if ([helpers isAcronym:[termList2 objectAtIndex:i]]){
                
                [suggestion_parts addObject:[[SuggestItem alloc]initSuggestItem:[termList2 objectAtIndex:i] :0 :0]];
                continue;
                
            }
            
        }
        
        suggestions = [self lookupRealmForWord:[termList1 objectAtIndex:i] maxEditDistance:maxEditDistance verbosity:2 includeUnknown:true];
        
        // combi check, always before split
        
        if (i > 0 && !isLastCombi){
            
            NSArray<SuggestItem*> *suggestionsCombi = [self lookupRealmForWord:[NSString stringWithFormat:@"%@%@",[termList1 objectAtIndex:i-1], [termList1 objectAtIndex:i]] maxEditDistance:maxEditDistance verbosity:2 includeUnknown:true];
            
            if (suggestionsCombi.count > 0){
                
                SuggestItem *best1 = [suggestion_parts lastObject];
                SuggestItem *best2;
                
                if(suggestions.count > 0){
                    
                    best2 = [suggestions objectAtIndex:0];
                    
                }else{
                    
                    best2 = [[SuggestItem alloc]initSuggestItem:[termList1 objectAtIndex:i] :maxEditDistance+1 :0];
                    
                }
                
                // make sure we're comparing with the lowercase form of the previous word
                
                int distance1 = [distanceComparer getLevenshteinDistance:[NSString stringWithFormat:@"%@ %@",[termList1 objectAtIndex:i-1], [termList1 objectAtIndex:i]] :[NSString stringWithFormat:@"%@ %@",best1.term.lowercaseString, best2.term.lowercaseString] :maxEditDistance];
                
                if (distance1 >= 0 && [suggestionsCombi objectAtIndex:0].distance + 1 < distance1){
                    
                    [suggestionsCombi objectAtIndex:0].distance += 1;
                    [suggestion_parts replaceObjectAtIndex:[suggestion_parts count]-1 withObject:[suggestionsCombi objectAtIndex:0]];
                    isLastCombi = true;
                    continue;
                }
                
            }
            
        }
        
        isLastCombi = false;
        
        // always split terms without suggestion / never split terms with suggestion ed=0 / never split single char terms
        
        if (suggestions.count > 0 && ([suggestions objectAtIndex:0].distance == 0 || [termList1 objectAtIndex:i].length == 1)){
            
            [suggestion_parts addObject:[suggestions objectAtIndex:0]];
            
        }else{
            
            // if no perfect suggestion, split word into pairs
            
            NSMutableArray<SuggestItem *> *suggestionsSplit = [[NSMutableArray alloc]init];
            
            // add original term
            
            if (suggestions.count > 0){
                
                [suggestionsSplit addObject:suggestions[0]];
                
            }
            
            if ([termList1 objectAtIndex:i].length > 1){
                
                for (int j = 1; j < [termList1 objectAtIndex:i].length; j++){
                    NSString *part1 = [[termList1 objectAtIndex:i] substringToIndex:j];
                    NSString *part2 = [[termList1 objectAtIndex:i] substringFromIndex:j+1];
                    
                    NSArray<SuggestItem *> *suggestions1 = [self lookupRealmForWord:part1 maxEditDistance:maxEditDistance verbosity:2 includeUnknown:true];
                    
                    if (suggestions1.count > 0){
                        
                        // if split correction1 == einzelwort correction
                        
                        if (suggestions.count > 0 && [[suggestions objectAtIndex:0].term isEqualToString:[suggestions1 objectAtIndex:0].term]){
                            
                            break;
                            
                        }
                        
                        NSArray<SuggestItem *> *suggestions2 = [self lookupRealmForWord:part2 maxEditDistance:maxEditDistance verbosity:2 includeUnknown:true];
                        
                        if (suggestions2.count > 0){
                            
                            // if split correction1 == einzelwort correction
                            
                            if (suggestions.count > 0 && [[suggestions objectAtIndex:0].term isEqualToString:[suggestions2 objectAtIndex:0].term]){
                                
                                break;
                                
                            }
                            
                            // select best suggestion for split pair
                            
                            NSString *tempTerm = [NSString stringWithFormat:@"%@ %@", [suggestions1 objectAtIndex:0].term, [suggestions2 objectAtIndex:0].term];
                            
                            int tempDistance = [distanceComparer getLevenshteinDistance:[termList1 objectAtIndex:i] :tempTerm :maxEditDistance];
                            
                            if (tempDistance < 0){
                                tempDistance = maxEditDistance + 1;
                            }
                            
                            int64_t tempCount = MIN((int)[suggestions1 objectAtIndex:0].count, (int)[suggestions2 objectAtIndex:0].count);
                            
                            SuggestItem *suggestionSplit = [[SuggestItem alloc]initSuggestItem:tempTerm :tempDistance :tempCount];
                            
                            [suggestionsSplit addObject:suggestionSplit];
                            
                            // early termination of split
                            
                            if (suggestionSplit.distance == 1){
                                break;
                            }
                            
                        }
                        
                    }
                    
                }
                
                if (suggestionsSplit.count > 0){
                    
                    // select best suggestion for split pair
                    
                    NSArray *suggestionSplitSorted = [self sortedSuggestionList:suggestionsSplit];
                    
                    [suggestion_parts addObject:[suggestionSplitSorted objectAtIndex:0]];
                    
                }else{
                    
                    SuggestItem *si = [[SuggestItem alloc]initSuggestItem:[termList1 objectAtIndex:i] :maxEditDistance + 1 :0];
                    
                    [suggestion_parts addObject:si];
                    
                }
                
            }else{
                SuggestItem *si = [[SuggestItem alloc]initSuggestItem:[termList1 objectAtIndex:i] :maxEditDistance + 1 :0];
                [suggestion_parts addObject:si];
            }
            
        }
        
        
    }
    
    NSMutableString *joinedTerm = [[NSMutableString alloc]init];
    
    long joinedCount = LONG_MAX;
    
    for (SuggestItem *si in suggestion_parts){
        
        [joinedTerm appendString:[NSString stringWithFormat:@"%@ ",si.term]];
        joinedCount = MIN(joinedCount, si.count);
        
    }
    
    SuggestItem *suggestion = [[SuggestItem alloc]initSuggestItem:[self removeEndSpaceFrom:joinedTerm] :[distanceComparer getLevenshteinDistance:phrase :joinedTerm :2^31 - 1] :joinedCount];
    
    NSMutableArray<SuggestItem*> *suggestionLine = [[NSMutableArray alloc]init];
    [suggestionLine addObject:suggestion];
    
    return suggestionLine;
    
}

- (NSString *)removeEndSpaceFrom:(NSString *)strtoremove{
    NSUInteger location = 0;
    unichar charBuffer[[strtoremove length]];
    [strtoremove getCharacters:charBuffer];
    int i = 0;
    for(i = (int)[strtoremove length]; i >0; i--) {
        NSCharacterSet* charSet = [NSCharacterSet whitespaceCharacterSet];
        if(![charSet characterIsMember:charBuffer[i - 1]]) {
            break;
        }
    }
    return [strtoremove substringWithRange:NSMakeRange(location, i  - location)];
}

- (BOOL) deleteInSuggestionPrefix: (NSString *)delete :(int)deleteLen :(NSString *)suggestion :(int)suggestionLen{

    /*check whether all delete chars are present in the suggestion prefix in correct
     order, otherwise this is just a hash collision*/

    if (deleteLen == 0){
        return true;
    }

    if (_prefixLength < suggestionLen){
        suggestionLen = _prefixLength;
    }

    int j = 0;

    for (int i = 0; i < deleteLen; i++){

        char delChar = [delete characterAtIndex:i];

        while (j < suggestionLen && ![[NSString stringWithFormat:@"%c", delChar] isEqualToString:[NSString stringWithFormat:@"%c", [suggestion characterAtIndex:j]]]) {

            j += 1;

        }

        if (j == suggestionLen){
            return false;
        }

    }

    return true;
}

-(NSArray*)sortedSuggestionList:(NSArray*)suggestionList
{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, nil];
    
    NSArray *sortedArray = [suggestionList sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}


- (NSMutableArray *)earlyExit{

    if (_includeUnknown && !_suggestions){
        [_suggestions addObject: [[SuggestItem alloc]initSuggestItem:_phrase :_maxEditDistance+1 :0]];
    }

    return _suggestions;

}

- (void)setVerbosity: (int)versbose{

    _verbosityTOP = false;
    _verbosityCLOSEST = false;
    _verbosityALL = false;

    switch (versbose) {
        case 0:
            _verbosityTOP = true;
            break;
        case 1:
            _verbosityCLOSEST = true;
            break;
        case 2:
            _verbosityALL = true;
            break;
        default:
            _verbosityTOP = true;
            break;
    }
}

@end
