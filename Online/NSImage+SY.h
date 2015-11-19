//
//  NSImage+SY.h
//  Online
//
//  Created by Stan Chevallier on 19/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (SY)

+ (NSImage *)imageWithColor:(NSColor *)color;
+ (NSImage *)imageWithColor:(NSColor *)color size:(NSSize)size;

@end
