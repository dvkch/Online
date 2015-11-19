//
//  NSImage+SY.m
//  Online
//
//  Created by Stan Chevallier on 19/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "NSImage+SY.h"

@implementation NSImage (SY)

+ (NSImage *)imageWithColor:(NSColor *)color
{
    return [self imageWithColor:color size:NSMakeSize(1, 1)];
}

+ (NSImage *)imageWithColor:(NSColor *)color size:(NSSize)size
{
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [color drawSwatchInRect:(NSRect){NSZeroPoint, size}];
    [image unlockFocus];
    return image;
}

@end
