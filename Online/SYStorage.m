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

- (void)addWebsite:(SYWebsiteModel *)website
{
    BOOL exists = [self.set containsObject:website];
    [self.set addObject:website];

    if (self.websiteAddedBlock && !exists)
        self.websiteAddedBlock(website);

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
