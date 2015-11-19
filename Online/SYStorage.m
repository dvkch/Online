//
//  SYStorage.m
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYStorage.h"

@interface SYStorage ()
@property (nonatomic, strong) NSMutableOrderedSet <SYWebsiteModel *> *set;
@end

@implementation SYStorage

+ (SYStorage *)shared
{
    static dispatch_once_t onceToken;
    static SYStorage *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"websites"];
        NSArray *savedItems = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : @[];
        self.set = [[NSMutableOrderedSet alloc] initWithArray:savedItems];
    }
    return self;
}

#pragma mark - Colors

- (NSColor *)defaultColorSuccess
{
    return [NSColor colorWithCalibratedRed:0. green:.82 blue:.32 alpha:1.];
}

- (NSColor *)colorSuccess
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorSuccess"];
    if (!data) return [self defaultColorSuccess];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)setColorSuccess:(NSColor *)colorSuccess
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(colorSuccess ?: [NSColor clearColor])];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"colorSuccess"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.colorSettingsChanged)
        self.colorSettingsChanged();
}

- (NSColor *)defaultColorTimeout
{
    return [NSColor colorWithCalibratedRed:1. green:.75 blue:.29 alpha:1.];
}

- (NSColor *)colorTimeout
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorTimeout"];
    if (!data) return [self defaultColorTimeout];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)setColorcolorTimeout:(NSColor *)colorcolorTimeout
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(colorcolorTimeout ?: [NSColor clearColor])];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"colorcolorTimeout"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.colorSettingsChanged)
        self.colorSettingsChanged();
}

- (NSColor *)defaultColorFailure
{
    return [NSColor colorWithCalibratedRed:1. green:.34 blue:.37 alpha:1.];
}

- (NSColor *)colorFailure
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorFailure"];
    if (!data) return [self defaultColorFailure];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)setColorFailure:(NSColor *)colorFailure
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(colorFailure ?: [NSColor clearColor])];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"colorFailure"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.colorSettingsChanged)
        self.colorSettingsChanged();
}

#pragma mark - Websites

- (void)addWebsite:(SYWebsiteModel *)website
{
    [self.set addObject:website];

    if (self.websitesUpdatedBlock)
        self.websitesUpdatedBlock();

    [self save];
}

- (void)removeWebsite:(SYWebsiteModel *)website
{
    [self.set removeObject:website];
    [self save];
}

- (NSArray<SYWebsiteModel *> *)websites
{
    return self.set.array;
}

- (NSArray<SYProxyModel *> *)proxies
{
    NSMutableArray *proxies = [NSMutableArray array];
    for (SYWebsiteModel *website in self.set)
        if (website.proxy.host.length && website.proxy.port)
            [proxies addObject:website.proxy];
    return [proxies copy];
}

- (SYWebsiteModel *)websiteForId:(NSString *)identifier
{
    for (SYWebsiteModel *website in self.set)
        if ([website.identifier isEqualToString:identifier])
            return website;
    return nil;
}

- (void)save
{
    NSData *websites = [NSKeyedArchiver archivedDataWithRootObject:self.set.array];
    [[NSUserDefaults standardUserDefaults] setObject:websites forKey:@"websites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
