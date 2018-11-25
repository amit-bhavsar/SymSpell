//
//  HelpersForTapAutocorrect.m
//  SymSpell_Compound
//
//  Created by Amit Bhavsar on 10/30/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "HelpersForTapAutocorrect.h"

@implementation HelpersForTapAutocorrect

- (int) nullDiatanceResults: (NSString *)string1 :(NSString *)string2 :(int)maxDistance{
    
    /*Determines the proper return value of an edit distance function when
    one or both strings are null.
    */
    
    if (string1 == NULL || string1.length == 0 || string1 == nil){
        
        if (string2 == NULL || string2.length == 0 || string2 == nil){
            
            return 0;
            
        }else{
            
            if (string2.length <= maxDistance -1){
                
                return (int)string2.length;
                
            }else{
                
                return -1;
                
            }
        
        }
    
    }else{
        
        if (string1.length <= maxDistance){
            
            return (int)string1.length;
            
        }else{
            
            return -1;
            
        }
        
    }

}

- (NSArray *)parseWords: (NSString *)phrase :(BOOL)preserveCase{
    
    /*create a non-unique wordlist from sample text language independent (e.g. works with Chinese characters) */
    
    // \W non-words, use negated set to ignore non-words and "_" (underscore)
    // Compatible with non-latin characters, does not split words at
    // apostrophes
     
    NSString *pattern = @"([^\\W_]+['']*[^\\W_]*)";
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern options: 0 error: &error];
    
    NSArray *matches = [regex matchesInString:phrase options:0 range:NSMakeRange(0, [phrase length])];
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        [result addObject: [phrase substringWithRange: match.range]];
    }
    
    return result;
    
}

- (BOOL)isAcronym: (NSString *)word{
    
    /*Checks is the word is all caps (acronym) and/or contain numbers
    
     Return:
     True if the word is all caps and/or contain numbers, e.g., ABCDE, AB12C
        False if the word contains lower case letters, e.g., abcde, ABCde, abcDE,
            abCDe, abc12, ab12c*/
    
    NSCharacterSet *charactersToCheck = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVW‌​XYZ0123456789"] invertedSet];
    
    if ([word rangeOfCharacterFromSet:charactersToCheck].location != NSNotFound) {
        return false;
    }else{
        return true;
    }
    
}


- (int)tryParseInst64: (NSString *)string{
    
    int ret = [string intValue];
    
    if (ret < pow(-2, 64) || ret >= pow(-2, 64)){
        return 0;
    }else{
        return ret;
    }
    
    return ret;
}

@end
