//
//  SYProxyModel.m
//  Proxy
//
//  Created by Stanislas Chevallier on 03/06/15.
//  Copyright (c) 2015 Syan. All rights reserved.
//

#import "SYProxyModel.h"

@interface SYProxyModel ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@end

@implementation SYProxyModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.identifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    self = [self init];
    if (self)
    {
        self.host = host;
        self.port = port;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        self.identifier       = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"identifier"];
        self.host             = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"host"];
        self.port             = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"port"] intValue];
        self.username         = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"username"];
        self.password         = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"password"];
        self.urlWildcardRules = [aDecoder decodeObjectOfClass:[NSArray  class] forKey:@"urlWildcardRule"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier        forKey:@"identifier"];
    [aCoder encodeObject:self.host              forKey:@"host"];
    [aCoder encodeObject:@(self.port)           forKey:@"port"];
    [aCoder encodeObject:self.username          forKey:@"username"];
    [aCoder encodeObject:self.password          forKey:@"password"];
    [aCoder encodeObject:self.urlWildcardRules  forKey:@"urlWildcardRule"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)copy
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    SYProxyModel *copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    copy.identifier = [[NSUUID UUID] UUIDString];
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
        return [[(SYProxyModel *)object identifier] isEqualToString:self.identifier];
    return NO;
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (BOOL)isValidForURL:(NSURL *)url
{
    for (NSString *rule in self.urlWildcardRules)
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self LIKE %@", rule];
        if ([pred evaluateWithObject:url.absoluteString])
            return YES;
    }
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; %@:%d>", [self class], self, self.host, self.port];
}

+ (SYProxyModel *)firstProxyInProxies:(NSArray *)proxies matchingURL:(NSURL *)url
{
    for (SYProxyModel *proxy in proxies)
        if ([proxy isValidForURL:url])
            return proxy;
    return nil;
}

@end
