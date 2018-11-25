//
//  KeyMap.m
//  SwipeType
//
//  Created by Amit Bhavsar on 10/5/18.
//  Copyright © 2018 Amit Bhavsar. All rights reserved.
//

#import "KeyMap.h"

@implementation KeyMap

- (NSString *) MapStringMultiRow :(char)letter {
    
    NSString *mappedString;
    
    switch (letter) {
            
        case 'a':
            mappedString =  @"asqwz";
            break;
            
        case 'b':
            mappedString =  @"bvnghj";
            break;
            
        case 'c':
            mappedString =  @"cxvdfg";
            break;
            
        case 'd':
            mappedString =  @"sdferx";
            break;
            
        case 'e':
            mappedString =  @"ewrsd";
            break;
            
        case 'f':
            mappedString =  @"dfgrtc";
            break;
            
        case 'g':
            mappedString =  @"fghtyv";
            break;
            
        case 'h':
            mappedString =  @"ghjyub";
            break;
            
        case 'i':
            mappedString =  @"uiojk";
            break;
            
        case 'j':
            mappedString =  @"hjkuin";
            break;
            
        case 'k':
            mappedString =  @"jkliom";
            break;
            
        case 'l':
            mappedString =  @"klmop";
            break;
            
        case 'm':
            mappedString =  @"nmjkl";
            break;
            
        case 'n':
            mappedString =  @"bnmj";
            break;
            
        case 'o':
            mappedString =  @"iopkl";
            break;
            
        case 'p':
            mappedString =  @"opl";
            break;
            
        case 'q':
            mappedString =  @"qwa";
            break;
            
        case 'r':
            mappedString =  @"ertdf";
            break;
            
        case 's':
            mappedString =  @"asdxwe";
            break;
            
        case 't':
            mappedString =  @"rtyfg";
            break;
            
        case 'u':
            mappedString =  @"yuihj";
            break;
            
        case 'v':
            mappedString =  @"cvbg";
            break;
            
        case 'w':
            mappedString =  @"qweas";
            break;
            
        case 'x':
            mappedString =  @"zxcd";
            break;
            
        case 'y':
            mappedString =  @"tyugh";
            break;
            
        case 'z':
            mappedString =  @"zxsd";
            break;
            
        default:
            break;
    }
    
    return mappedString;
    
}

- (NSString *) MapStringSameRow :(char)letter {
    
    NSString *mappedString;
    
    switch (letter) {
            
        case 'a':
            mappedString =  @"as";
            break;
            
        case 'b':
            mappedString =  @"vbn";
            break;
            
        case 'c':
            mappedString =  @"xcv";
            break;
            
        case 'd':
            mappedString =  @"sdf";
            break;
            
        case 'e':
            mappedString =  @"wer";
            break;
            
        case 'f':
            mappedString =  @"dfg";
            break;
            
        case 'g':
            mappedString =  @"fgh";
            break;
            
        case 'h':
            mappedString =  @"ghj";
            break;
            
        case 'i':
            mappedString =  @"uio";
            break;
            
        case 'j':
            mappedString =  @"hjk";
            break;
            
        case 'k':
            mappedString =  @"jkl";
            break;
            
        case 'l':
            mappedString =  @"kl";
            break;
            
        case 'm':
            mappedString =  @"nm";
            break;
            
        case 'n':
            mappedString =  @"bnm";
            break;
            
        case 'o':
            mappedString =  @"iop";
            break;
            
        case 'p':
            mappedString =  @"op";
            break;
            
        case 'q':
            mappedString =  @"qw";
            break;
            
        case 'r':
            mappedString =  @"ert";
            break;
            
        case 's':
            mappedString =  @"asd";
            break;
            
        case 't':
            mappedString =  @"rty";
            break;
            
        case 'u':
            mappedString =  @"yui";
            break;
            
        case 'v':
            mappedString =  @"cvb";
            break;
            
        case 'w':
            mappedString =  @"qwe";
            break;
            
        case 'x':
            mappedString =  @"zxc";
            break;
            
        case 'y':
            mappedString =  @"tyu";
            break;
            
        case 'z':
            mappedString =  @"zx";
            break;
            
        default:
            break;
    }
    
    return mappedString;
    
}

@end
