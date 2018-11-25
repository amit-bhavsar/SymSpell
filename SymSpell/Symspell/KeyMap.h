//
//  KeyMap.h
//  SwipeType
//
//  Created by Amit Bhavsar on 10/5/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyMap : NSObject {
    
}

- (NSString *) MapStringMultiRow :(char)letter;
- (NSString *) MapStringSameRow :(char)letter;

@end
