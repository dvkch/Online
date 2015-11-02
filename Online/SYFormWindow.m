//
//  SYFormWindow.m
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYFormWindow.h"
#import "SYStorage.h"
#import "SYIntOnlyFormatter.h"

@interface SYFormWindow ()

@property (nonatomic, weak) IBOutlet NSTextField *fieldName;
@property (nonatomic, weak) IBOutlet NSTextField *fieldURL;
@property (nonatomic, weak) IBOutlet NSTextField *fieldProxyHost;
@property (nonatomic, weak) IBOutlet NSTextField *fieldProxyPort;
@property (nonatomic, weak) IBOutlet NSTextField *fieldProxyUser;
@property (nonatomic, weak) IBOutlet NSTextField *fieldProxyPass;
@property (nonatomic, weak) IBOutlet NSTextField *fieldTimeout;
@property (nonatomic, weak) IBOutlet NSTextField *fieldTimeBeforeRetryIfSuccess;
@property (nonatomic, weak) IBOutlet NSTextField *fieldTimeBeforeRetryIfFailed;
@property (nonatomic, weak) IBOutlet NSButton *buttonCancel;
@property (nonatomic, weak) IBOutlet NSView *containerView;

@end

@implementation SYFormWindow

+ (SYFormWindow *)windowForWebsite:(SYWebsiteModel *)website
{
    NSNib *nib = [[NSNib alloc] initWithNibNamed:[[self class] description] bundle:nil];
    NSArray *items;
    [nib instantiateWithOwner:nil topLevelObjects:&items];
    SYFormWindow *window;
    for (NSObject *item in items)
    {
        if ([item isKindOfClass:[self class]])
            window = (SYFormWindow *)item;
    }
    [window setWebsite:website];
    return window;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self.fieldProxyPort                setFormatter:[SYIntOnlyFormatter new]];
        [self.fieldTimeout                  setFormatter:[SYIntOnlyFormatter new]];
        [self.fieldTimeBeforeRetryIfSuccess setFormatter:[SYIntOnlyFormatter new]];
        [self.fieldTimeBeforeRetryIfFailed  setFormatter:[SYIntOnlyFormatter new]];
    }
    return self;
}

- (void)update
{
    [super update];
    if (self.website)
        [self setTitle:@"Edit website"];
    else
        [self setTitle:@"New website"];
}

- (void)setWebsite:(SYWebsiteModel *)website
{
    self->_website = website;
    [self updateWithWebsite:website];
}

- (void)updateWithWebsite:(SYWebsiteModel *)website
{
    [self.fieldName setStringValue:(self.website.name ?: @"")];
    [self.fieldURL  setStringValue:(self.website.url  ?: @"")];
    [self.fieldProxyHost    setStringValue:(self.website.proxy.host ?: @"")];
    [self.fieldProxyPort    setIntValue:self.website.proxy.port];
    [self.fieldProxyUser    setStringValue:(self.website.proxy.username ?: @"")];
    [self.fieldProxyPass    setStringValue:(self.website.proxy.password ?: @"")];
    [self.fieldTimeout                  setDoubleValue:self.website.timeout];
    [self.fieldTimeBeforeRetryIfSuccess setDoubleValue:self.website.timeBeforeRetryIfSuccessed];
    [self.fieldTimeBeforeRetryIfFailed  setDoubleValue:self.website.timeBeforeRetryIfFailed];
}

- (BOOL)checkValidity
{
    NSMutableArray *errors = [NSMutableArray array];
    if (!self.fieldName.stringValue.length)
        [errors addObject:@"name must not be empty"];
    if (!self.fieldURL.stringValue.length)
        [errors addObject:@"URL must not be empty"];
    
    if (!self.fieldProxyHost.stringValue.length && self.fieldProxyPort.integerValue)
        [errors addObject:@"proxy port is set but not the host"];
    if (self.fieldProxyHost.stringValue.length && !self.fieldProxyPort.integerValue)
        [errors addObject:@"proxy port must not be 0 or empty"];
    if (!self.fieldProxyUser.stringValue.length && self.fieldProxyPass.stringValue.length)
        [errors addObject:@"proxy username cannot be empty if you provide a password"];
    if (self.fieldProxyUser.stringValue.length && !self.fieldProxyHost.stringValue.length)
        [errors addObject:@"proxy user is defined but not the host"];
    
    if (self.fieldTimeout.doubleValue < 2)
        [errors addObject:@"timeout must be greater than 2s"];
    if (self.fieldTimeBeforeRetryIfSuccess.doubleValue < 5 || self.fieldTimeBeforeRetryIfFailed.doubleValue < 5)
        [errors addObject:@"time between requests must be greater than or equal to 5s"];
    if (self.fieldTimeout.intValue % 5 || self.fieldTimeBeforeRetryIfSuccess.intValue % 5 || self.fieldTimeBeforeRetryIfFailed.intValue % 5)
        [errors addObject:@"times must be multiples of 5"];
    
    if (errors.count == 0)
        return YES;
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Invalid configuration"];
    
    NSString *message = [NSString stringWithFormat:@"The following errors have been found:\n- %@", [errors componentsJoinedByString:@"\n- "]];
    [alert setInformativeText:message];
    
    [alert addButtonWithTitle:@"Close"];
    [alert beginSheetModalForWindow:self completionHandler:nil];
    
    return NO;
}

- (IBAction)saveButtonTap:(id)sender
{
    if (![self checkValidity])
        return;
    
    SYWebsiteModel *website = self.website;
    if (!website)
    {
        website = [[SYWebsiteModel alloc] init];
        website.proxy = [[SYProxyModel alloc] init];
    }

    website.name = self.fieldName.stringValue;
    website.url  = self.fieldURL.stringValue;
    website.proxy.host              = self.fieldProxyHost.stringValue;
    website.proxy.port              = self.fieldProxyPort.intValue;
    website.proxy.username          = self.fieldProxyUser.stringValue;
    website.proxy.password          = self.fieldProxyPass.stringValue;
    website.proxy.urlWildcardRules  = @[website.url];
    website.timeout                     = self.fieldTimeout.doubleValue;
    website.timeBeforeRetryIfSuccessed  = self.fieldTimeBeforeRetryIfSuccess.doubleValue;
    website.timeBeforeRetryIfFailed     = self.fieldTimeBeforeRetryIfFailed.doubleValue;
    
    [[SYStorage shared] addWebsite:website];
    [self close];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self close];
}

@end
