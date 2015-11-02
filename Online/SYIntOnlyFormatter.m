//
//  SYIntOnlyFormatter.m
//  Online
//
//  Created by Stan Chevallier on 28/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYIntOnlyFormatter.h"

@implementation SYIntOnlyFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end

