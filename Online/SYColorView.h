//
//  SYColorView.h
//  Online
//
//  Created by Stan Chevallier on 19/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SYColorView : NSControl

@property (nonatomic, strong) NSColor *color;

- (NSImage *)screenshot;
+ (NSImage *)screenshotForColor:(NSColor *)color size:(NSSize)size;

@end
