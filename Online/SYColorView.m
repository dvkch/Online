//
//  SYColorView.m
//  Online
//
//  Created by Stan Chevallier on 19/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYColorView.h"
#import "NSImage+SY.h"

@implementation SYColorView

- (void)setColor:(NSColor *)color
{
    [super setColor:[color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Width: 1px for 12 x 12 view
    CGFloat lineWidth = 1 * dirtyRect.size.width / 12.;
    
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:dirtyRect];
    
    NSRect rect = NSRectFromCGRect(CGRectInset(NSRectToCGRect(dirtyRect), lineWidth, lineWidth));
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithRoundedRect:rect
                                                               xRadius:dirtyRect.size.width/2.
                                                               yRadius:dirtyRect.size.height/2.];
    [circlePath setLineWidth:1];
    
    [self.color set];
    [circlePath fill];
    
    [[NSColor darkGrayColor] set];
    // TODO: [[self.color darkenColorByValue:0.1] set];
    [circlePath stroke];

    if ([self.window firstResponder] == self)
    {
        [NSGraphicsContext saveGraphicsState];
        {
            [[NSColor keyboardFocusIndicatorColor] set];
            NSSetFocusRingStyle(NSFocusRingOnly);
            [[NSBezierPath bezierPathWithOvalInRect:self.bounds] fill];
        }
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (NSImage *)screenshot
{
    return [[NSImage alloc] initWithData:[self dataWithPDFInsideRect:[self bounds]]];
}

+ (NSImage *)screenshotForColor:(NSColor *)color size:(NSSize)size
{
    SYColorView *colorView = [[SYColorView alloc] initWithFrame:(NSRect){NSZeroPoint, size}];
    [colorView setColor:color];
    return [colorView screenshot];
}

@end
