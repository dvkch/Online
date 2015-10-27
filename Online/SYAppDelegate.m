//
//  SYAppDelegate.m
//  Online
//
//  Created by Stan Chevallier on 26/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYAppDelegate.h"
#import "SYStorage.h"
#import "SYFormViewController.h"
#import "SYCrawler.h"

typedef void(^SYMenuTapBlock)(void);

@interface SYAppDelegate () <SYProxyURLProtocolDataSource, NSMenuDelegate>

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSImage *imageGreen;
@property (strong, nonatomic) NSImage *imageOrange;
@property (strong, nonatomic) NSImage *imageRed;
@property (strong, nonatomic) NSImage *imageGrey;
@property (strong, nonatomic) NSWindow *editWindow;

@end

@implementation SYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self.statusMenu setDelegate:self];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"traffic_grey"]];
    [self.statusItem setHighlightMode:YES];
    
    self.imageGrey   = [NSImage imageNamed:@"traffic_grey"];
    self.imageGreen  = [NSImage imageNamed:@"traffic_green"];
    self.imageOrange = [NSImage imageNamed:@"traffic_orange"];
    self.imageRed    = [NSImage imageNamed:@"traffic_red"];
    
    [[SYCrawler shared] setResultChangedBlock:^{
        [self updateIcon];
    }];
    
    [SYProxyURLProtocol setDataSource:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return NO;
}

#pragma mark - Menu

- (void)updateIcon
{
    NSArray *allResults = [[SYCrawler shared] allResults];
    
    BOOL hasError = NO;
    BOOL hasTimeout = NO;
    BOOL hasSuccess = NO;
    
    for (SYCrawlerResult *result in allResults)
    {
        switch (result.status) {
            case SYWebsiteStatus_On:        hasSuccess = YES; break;
            case SYWebsiteStatus_Timeout:   hasTimeout = YES; break;
            case SYWebsiteStatus_Error:     hasError   = YES; break;
            case SYWebsiteStatus_Unknown:   break;
        }
    }
    
    if (hasError)
    {
        [self.statusItem setImage:self.imageRed];
    }
    else if (hasTimeout)
    {
        [self.statusItem setImage:self.imageOrange];
    }
    else if (hasSuccess)
    {
        [self.statusItem setImage:self.imageGreen];
    }
    else
    {
        [self.statusItem setImage:self.imageGrey];
    }
}

- (NSImage *)imageForStatus:(SYWebsiteStatus)status
{
    switch (status) {
        case SYWebsiteStatus_Unknown:   return self.imageGrey;
        case SYWebsiteStatus_On:        return self.imageGreen;
        case SYWebsiteStatus_Timeout:   return self.imageOrange;
        case SYWebsiteStatus_Error:     return self.imageRed;
    }
    return nil;
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
    if (menu != self.statusMenu)
        return;
    
    [menu removeAllItems];
    for (SYWebsiteModel *website in [[SYStorage shared] websites])
    {
        SYCrawlerResult *result = [[SYCrawler shared] resultForWebsite:website.identifier];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:website.name action:nil keyEquivalent:@""];
        [item setImage:[self imageForStatus:result.status]];
        [item setSubmenu:[[NSMenu alloc] init]];
        [menu addItem:item];
        
        if (result)
        {
            NSMenuItem *itemStatus = [[NSMenuItem alloc] initWithTitle:result.detailedString action:nil keyEquivalent:@""];
            [item.submenu addItem:itemStatus];
        }
        
        NSMenuItem *itemEdit = [[NSMenuItem alloc] initWithTitle:@"Edit..." action:@selector(menuItemTapped:) keyEquivalent:@""];
        [itemEdit setTarget:self];
        [itemEdit setRepresentedObject:^{
            [self openEditViewForWebsite:website];
        }];
        [item.submenu addItem:itemEdit];
        
        NSMenuItem *itemDelete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuItemTapped:) keyEquivalent:@""];
        [itemDelete setTarget:self];
        [itemDelete setRepresentedObject:^{
            [[SYStorage shared] removeWebsite:website];
        }];
        [item.submenu addItem:itemDelete];
    }

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *itemAdd = [[NSMenuItem alloc] initWithTitle:@"Add new item..." action:@selector(menuItemTapped:) keyEquivalent:@""];
    [itemAdd setTarget:self];
    [itemAdd setRepresentedObject:^{
        [self openEditViewForWebsite:nil];
    }];
    [menu addItem:itemAdd];

    NSMenuItem *itemQuit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(menuItemTapped:) keyEquivalent:@""];
    [itemQuit setTarget:self];
    [itemQuit setRepresentedObject:^{
        [NSApp terminate:nil];
    }];
    [menu addItem:itemQuit];
}

- (void)menuItemTapped:(id)sender
{
    SYMenuTapBlock block = [(NSMenuItem *)sender representedObject];
    if (block) block();
}

#pragma mark - Edit/New

- (void)openEditViewForWebsite:(SYWebsiteModel *)website
{
    SYFormViewController *form = [[SYFormViewController alloc] init];
    [form setWebsite:website];
    
    [NSApp activateIgnoringOtherApps:YES];
    NSWindow *window = [[NSWindow alloc] initWithContentRect:form.view.bounds
                                                   styleMask:(NSTitledWindowMask|NSClosableWindowMask)
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO
                                                      screen:[NSScreen mainScreen]];
    [window setContentViewController:form];
    [window.contentView layoutSubtreeIfNeeded];
    [window setFrame:(NSRect){{0, 0}, [window.contentView frame].size} display:YES];
    [window setMovableByWindowBackground:YES];
    [window center];
    [window setLevel:NSScreenSaverWindowLevel + 1];
    [window setOpaque:YES];
    [window makeKeyAndOrderFront:NSApp];
    
    self.editWindow = window;
}

#pragma mark - Proxies

- (SYProxyModel *)firstProxyMatchingURL:(NSURL *)url
{
    return [SYProxyModel firstProxyInProxies:[[SYStorage shared] proxies] matchingURL:url];
}

@end
