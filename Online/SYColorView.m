//
//  SYColorView.m
//  Online
//
//  Created by Stan Chevallier on 19/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYColorView.h"
#import "NSImage+SY.h"
#import <NSColor+ColorExtensions.h>
#import <CLColorControllerPopove.h>

@interface SYColorView ()
@property (nonatomic, strong) NSPopover *popover;
@end

@implementation SYColorView

- (void)mouseUp:(NSEvent *)theEvent
{
    [self.popover close];
    
    if (NSPointInRect([self convertPoint:theEvent.locationInWindow fromView:nil], self.bounds))
        [self openPopoverWithFocusRings:NO];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([self.popover isShown])
        return;
    
    if (theEvent.keyCode == 49 || theEvent.keyCode == 36)
        return [self openPopoverWithFocusRings:YES];
    
    [super keyDown:theEvent];
}

- (void)setColor:(NSColor *)color
{
    self->_color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    [self setNeedsDisplay:YES];
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
    
    [[self.color darkenColorByValue:0.1] set];
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

- (void)openPopoverWithFocusRings:(BOOL)withFocusRings
{
    CLColorControllerPopove *controller = [[CLColorControllerPopove alloc] initWithNibName:[[CLColorControllerPopove class] description] bundle:nil];
    [controller setTarget:self];
    [controller setSelector:@selector(popoverDidSelectColor:)];
    
    if (withFocusRings)
    {
        for (NSButton *view in controller.view.subviews)
        {
            if ([view isKindOfClass:[NSButton class]])
            {
                NSColor *color = ((NSButtonCell *)view.cell).backgroundColor;
                [view setImage:[NSImage imageWithColor:color size:view.bounds.size]];
                [view setBordered:YES];
                [view setBezelStyle:NSRoundRectBezelStyle];
                [view setWantsLayer:YES];
            }
        }
    }
    
    self.popover = [[NSPopover alloc] init];
    self.popover.behavior = NSPopoverBehaviorTransient;
    [self.popover setContentViewController:controller];
    [self.popover setAnimates:NO];
    [self.popover showRelativeToRect:self.bounds ofView:self preferredEdge:NSMinYEdge];
}

- (BOOL)acceptsFirstResponder
{
    return (self.popover.shown ? NO : YES);
}

- (void)popoverDidSelectColor:(NSColor *)color
{
    [self.popover close];
    [self setColor:color];
    [self sendAction:self.action to:self.target];
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
