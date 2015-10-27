//
//  SYWebsiteModel.m
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYWebsiteModel.h"

@interface SYWebsiteModel ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@end

@implementation SYWebsiteModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.identifier                 = [aDecoder decodeObjectForKey:@"identifier"];
        self.name                       = [aDecoder decodeObjectForKey:@"name"];
        self.url                        = [aDecoder decodeObjectForKey:@"url"];
        self.timeout                    = [aDecoder decodeDoubleForKey:@"timeout"];
        self.timeBeforeRetryIfFailed    = [aDecoder decodeDoubleForKey:@"timeBeforeRetryIfFailed"];
        self.timeBeforeRetryIfSuccessed = [aDecoder decodeDoubleForKey:@"timeBeforeRetryIfSuccessed"];
        self.proxy                      = [aDecoder decodeObjectForKey:@"proxy"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier                    forKey:@"identifier"];
    [aCoder encodeObject:self.name                          forKey:@"name"];
    [aCoder encodeObject:self.url                           forKey:@"url"];
    [aCoder encodeDouble:self.timeout                       forKey:@"timeout"];
    [aCoder encodeDouble:self.timeBeforeRetryIfFailed       forKey:@"timeBeforeRetryIfFailed"];
    [aCoder encodeDouble:self.timeBeforeRetryIfSuccessed    forKey:@"timeBeforeRetryIfSuccessed"];
    [aCoder encodeObject:self.proxy                         forKey:@"proxy"];
}

- (NSString *)identifier
{
    if (!self->_identifier)
        self->_identifier = [[NSUUID UUID] UUIDString];
    return self->_identifier;
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return NO;
    return [self.identifier isEqualToString:[(SYWebsiteModel *)object identifier]];
}

@end
