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
#import "SYSettingsViewController.h"
#import "SYCrawler.h"
#import "SYColorView.h"

typedef void(^SYMenuTapBlock)(void);

@interface SYAppDelegate () <SYProxyURLProtocolDataSource, NSMenuDelegate>

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSImage *imageSuccess;
@property (strong, nonatomic) NSImage *imageTimeout;
@property (strong, nonatomic) NSImage *imageFailure;
@property (strong, nonatomic) NSImage *imageGrey;
@property (strong, nonatomic) NSPopover *popover;

@end

@implementation SYAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self updateImages];
    
    [self.statusMenu setDelegate:self];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:self.imageGrey];
    [self.statusItem setHighlightMode:YES];
    
    [[SYCrawler shared] setResultChangedBlock:^{
        [self updateIcon];
    }];
    
    [[SYStorage shared] setColorSettingsChanged:^{
        [self updateImages];
        [self updateIcon];
    }];
    
    [SYProxyURLProtocol setDataSource:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return NO;
}

#pragma mark - Images

- (void)updateImages
{
    self.imageGrey    = [SYColorView screenshotForColor:[NSColor colorWithCalibratedWhite:0.6 alpha:1.] size:NSMakeSize(12, 12)];
    self.imageSuccess = [SYColorView screenshotForColor:[[SYStorage shared] colorSuccess] size:NSMakeSize(12, 12)];
    self.imageTimeout = [SYColorView screenshotForColor:[[SYStorage shared] colorTimeout] size:NSMakeSize(12, 12)];
    self.imageFailure = [SYColorView screenshotForColor:[[SYStorage shared] colorFailure] size:NSMakeSize(12, 12)];
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
        [self.statusItem setImage:self.imageFailure];
    }
    else if (hasTimeout)
    {
        [self.statusItem setImage:self.imageTimeout];
    }
    else if (hasSuccess)
    {
        [self.statusItem setImage:self.imageSuccess];
    }
    else
    {
        [self.statusItem setImage:self.imageGrey];
    }
    
    for (NSMenuItem *item in self.statusItem.menu.itemArray)
    {
        if ([item.representedObject isKindOfClass:[NSString class]])
        {
            SYCrawlerResult *result = [[SYCrawler shared] resultForWebsite:item.representedObject];
            [item setImage:[self imageForStatus:result.status]];
        }
    }
}

- (NSImage *)imageForStatus:(SYWebsiteStatus)status
{
    switch (status) {
        case SYWebsiteStatus_Unknown:   return self.imageGrey;
        case SYWebsiteStatus_On:        return self.imageSuccess;
        case SYWebsiteStatus_Timeout:   return self.imageTimeout;
        case SYWebsiteStatus_Error:     return self.imageFailure;
    }
    return nil;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self.popover close];
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
        [item setRepresentedObject:website.identifier];
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
            [self openFormForWebsite:website];
        }];
        [item.submenu addItem:itemEdit];
        
        NSMenuItem *itemDelete = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(menuItemTapped:) keyEquivalent:@""];
        [itemDelete setTarget:self];
        [itemDelete setRepresentedObject:^{
            NSString *msg = [NSString stringWithFormat:@"Are you sure you want to delete %@ ?", website.name];
            NSAlert *alert = [NSAlert alertWithMessageText:msg defaultButton:@"No" alternateButton:@"Yes" otherButton:nil informativeTextWithFormat:@"This is operation cannot be undone"];
            if ([alert runModal] == 0)
            {
                [[SYStorage shared] removeWebsite:website];
            }
        }];
        [item.submenu addItem:itemDelete];
    }

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *itemAdd = [[NSMenuItem alloc] initWithTitle:@"Add new item..." action:@selector(menuItemTapped:) keyEquivalent:@""];
    [itemAdd setTarget:self];
    [itemAdd setRepresentedObject:^{
        [self openFormForWebsite:nil];
    }];
    [menu addItem:itemAdd];
    
    NSMenuItem *itemSettings = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(menuItemTapped:) keyEquivalent:@""];
    [itemSettings setTarget:self];
    [itemSettings setRepresentedObject:^{
        [self openSettings];
    }];
    [menu addItem:itemSettings];
    
    NSMenuItem *itemQuit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(menuItemTapped:) keyEquivalent:@""];
    [itemQuit setTarget:self];
    [itemQuit setRepresentedObject:^{
        [NSApp terminate:nil];
    }];
    [menu addItem:itemQuit];
}

- (void)menuItemTapped:(NSMenuItem *)sender
{
    SYMenuTapBlock block = sender.representedObject;
    if (block) block();
}

#pragma mark - Form

- (void)openFormForWebsite:(SYWebsiteModel *)website
{
    SYFormViewController *vc = [SYFormViewController viewControllerForWebsite:website];
    [self openPopoverForViewController:vc];
}

- (void)openSettings
{
    SYSettingsViewController *vc = [SYSettingsViewController viewController];
    [self openPopoverForViewController:vc];
}

- (void)openPopoverForViewController:(NSViewController *)viewController
{
    [self.popover close];
    
    self.popover = [[NSPopover alloc] init];
    self.popover.behavior = NSPopoverBehaviorTransient;
    [self.popover setContentViewController:viewController];
    [self.popover setAnimates:NO];
    [self.popover showRelativeToRect:self.statusItem.button.frame ofView:self.statusItem.button preferredEdge:NSMinYEdge];
}

#pragma mark - Proxies

- (SYProxyModel *)firstProxyMatchingURL:(NSURL *)url
{
    return [SYProxyModel firstProxyInProxies:[[SYStorage shared] proxies] matchingURL:url];
}

@end
