//
//  WeightedDistance.m
//  WeightedDistance
//
//  Created by Amit Bhavsar on 11/11/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "WeightedDistance.h"

@implementation WeightedDistance

- (Distance *) GetWeightedDistanceBetweenUserWord:(NSString *)string1 andSystemWord:(NSString *)string2{
    
    int maxDistance = 2; // only 2 edits are allowed. edits include transpose/add/delete
    int levenshteinDistance = 0; // distance for edits
    float weightedDistance = 0; // distance based on proximity
    
    KeyMap *keyMap = [[KeyMap alloc]init];
    
    Distance *distance = [[Distance alloc]init];
    
    if (string1 == (id)[NSNull null] || string1.length == 0 || string2 == (id)[NSNull null] || string2.length == 0 ){
        distance.levenshteinDistance = -1;
        distance.weightedDistance = 0.0;
        return distance;
    }
    
    // if strings of different lengths, ensure shorter string is in string1. This can result in a little
    
    // faster speed by spending more time spinning just the inner loop during the main processing.
    
    if (string1.length > string2.length) {
        
        NSString *temp = string1; string1 = string2; string2 = temp; // swap string1 and string2
        
    }
    
    int sLen = (int)string1.length; // this is also the minimun length of the two strings
    
    int tLen = (int)string2.length;
    
    while ((sLen > 0) && ([[NSString stringWithFormat:@"%c", [string1 characterAtIndex:sLen - 1]] isEqualToString:[NSString stringWithFormat:@"%c", [string2 characterAtIndex:tLen - 1]]] || [[keyMap MapStringSameRow:[string1 characterAtIndex:sLen - 1]] containsString:[NSString stringWithFormat:@"%c",[string2 characterAtIndex:tLen - 1]]])) {
        
        if ([[NSString stringWithFormat:@"%c", [string1 characterAtIndex:sLen - 1]] isEqualToString:[NSString stringWithFormat:@"%c", [string2 characterAtIndex:tLen - 1]]]){
            levenshteinDistance += 0;
        }else{
            weightedDistance += 0.2;
        }
        
        sLen--; tLen--;
        
    }
    
    
    int start = 0;
    
    if (([[NSString stringWithFormat:@"%c", [string1 characterAtIndex:0]] isEqualToString:[NSString stringWithFormat:@"%c", [string2 characterAtIndex:0]]]) || (sLen == 0))
        
    {
        // if there'string1 a shared prefix, or all string1 matches string2'string1 suffix
        
        // prefix common to both strings can be ignored
        
        while ((start < sLen) && ([[NSString stringWithFormat:@"%c", [string1 characterAtIndex:start]] isEqualToString:[NSString stringWithFormat:@"%c", [string2 characterAtIndex:start]]])) start++;
        
        // length of the part excluding common prefix and suffix
        
        sLen -= start;
        
        tLen -= start;
        
        // if all of shorter string matches prefix and/or suffix of longer string, then
        
        // edit distance is just the delete of additional characters present in longer string
        
        if (sLen == 0){
            distance.levenshteinDistance = tLen;
            distance.weightedDistance = weightedDistance;
            return distance;
        }
        
        // faster than string2[start+j] in inner loop below
        //***** check here
        string2 = [string2 substringWithRange:NSMakeRange (start, tLen)];
        
    }else if (([[keyMap MapStringSameRow:[string1 characterAtIndex:0]] containsString:[NSString stringWithFormat:@"%c",[string2 characterAtIndex:0]]]) || (sLen == 0))
        
    {
        // if there'string1 a shared prefix, or all string1 matches string2'string1 suffix
        
        // prefix common to both strings can be ignored
        
        while ((start < sLen) && ([[keyMap MapStringSameRow:[string1 characterAtIndex:start]] containsString:[NSString stringWithFormat:@"%c",[string2 characterAtIndex:start]]])){
            start++;
            weightedDistance += 0.2;
        }
        
        // length of the part excluding common prefix and suffix
        
        sLen -= start;
        
        tLen -= start;
        
        // if all of shorter string matches prefix and/or suffix of longer string, then
        
        // edit distance is just the delete of additional characters present in longer string
        
        if (sLen == 0){
            distance.levenshteinDistance = tLen;
            distance.weightedDistance = weightedDistance;
            return distance;
        }
        
        // faster than string2[start+j] in inner loop below
        //***** check here
        string2 = [string2 substringWithRange:NSMakeRange (start, tLen)];
        
    }
    
    int lenDiff = tLen - sLen;
    
    if ((maxDistance < 0) || (maxDistance > tLen)) {
        
        maxDistance = tLen;
        
    } else if (lenDiff > maxDistance) {
        
        distance.levenshteinDistance = -1;
        distance.weightedDistance = weightedDistance;
        return distance;
        
    }
    
    int v0[tLen];
    int v2[sLen];
    
    int j;
    for (j = 0; j < maxDistance; j++) v0[j] = j + 1;
    for (; j < tLen; j++) v0[j] = maxDistance + 1;
    
    int jStartOffset = maxDistance - (tLen - sLen);
    
    BOOL haveMax = maxDistance < tLen;
    
    int jStart = 0;
    int jEnd = maxDistance;
    char sChar = [string1 characterAtIndex:0];
    int current = 0;
    int thisTransCost= 0;
    for (int i = 0; i < sLen; i++) {
        char prevsChar = sChar;
        sChar = [string1 characterAtIndex:(start + i)];
        char tChar = [string2 characterAtIndex:0];
        int left = i;
        current = left + 1;
        int nextTransCost = 0;
        // no need to look beyond window of lower right diagonal - maxDistance cells (lower right diag is i - lenDiff)
        // and the upper left diagonal + maxDistance cells (upper left is i)
        jStart += (i > jStartOffset) ? 1 : 0;
        jEnd += (jEnd < tLen) ? 1 : 0;
        for (j = jStart; j < jEnd; j++) {
            int above = current;
            thisTransCost = nextTransCost;
            nextTransCost = v2[j];
            v2[j] = current = left; // cost of diagonal (substitution)
            left = v0[j];    // left now equals current cost (which will be diagonal at next iteration)
            char prevtChar = tChar;
            tChar = [string2 characterAtIndex:j];
            
            NSString *sCharMap = [keyMap MapStringSameRow:sChar];
            NSString *prevCharMap = [keyMap MapStringSameRow:prevsChar];
            if (sChar != tChar && ![sCharMap containsString:[NSString stringWithFormat:@"%c",tChar]]) {
                if (left < current) current = left;   // insertion
                if (above < current) current = above; // deletion
                current++;
                if ((i != 0) && (j != 0)
                    && (sChar == prevtChar || [sCharMap containsString:[NSString stringWithFormat:@"%c",prevtChar]])
                    && (prevsChar == tChar  || [prevCharMap containsString:[NSString stringWithFormat:@"%c",tChar]])) {
                    
                    thisTransCost++;
                    if (sChar != prevtChar && prevsChar != tChar){
                        weightedDistance += 0.2;
                    }else if (sChar == prevtChar && prevsChar != tChar){
                        weightedDistance += 0.2;
                    }else if (sChar != prevtChar && prevsChar == tChar){
                        weightedDistance += 0.2;
                    }
                    
                    if (thisTransCost < current) current = thisTransCost; // transposition
                }
            }
            v0[j] = current;
        }
        if (haveMax && (v0[i + lenDiff] > maxDistance)){
            distance.levenshteinDistance = -1;
            distance.weightedDistance = weightedDistance;
        }
    }
    
    //NSLog(@"trans: %i", thisTransCost);
    distance.levenshteinDistance = (current <= maxDistance) ? current : -1;
    distance.weightedDistance = weightedDistance;
    
    return distance;
}

@end
