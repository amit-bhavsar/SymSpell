//
//  LevenshteinDistance.h
//  TwoThumbs
//
//  Created by Sunil TAYI on 8/5/17.
//  Copyright © 2017 AspenBytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevenshteinDistance : NSObject

- (int) getLevenshteinDistance : (NSString *) systemWord :(NSString *) enteredWord :(int) maxDistance;

@end
