//
//  SYCrawlerResult.m
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYCrawlerResult.h"

@implementation SYCrawlerResult

- (instancetype)initWithStatusCode:(NSInteger)statusCode andError:(NSError *)error
{
    self = [super init];
    if (self) {
        self.statusCode = statusCode;
        self.error = error;
    }
    return self;
}

- (NSString *)detailedString
{
    if (self.statusCode)
        return [NSString stringWithFormat:@"HTTP %ld", (long)self.statusCode];
    if ([self.error.domain isEqualToString:NSURLErrorDomain] && self.error.code == NSURLErrorTimedOut)
        return @"Timeout";
    if (self.error)
        return [self.error localizedDescription];
    return @"Unknown";
}

- (SYWebsiteStatus)status
{
    if (self.statusCode == 200)
    {
        return SYWebsiteStatus_On;
    }
    else if([self.error.domain isEqualToString:NSURLErrorDomain] && self.error.code == NSURLErrorTimedOut)
    {
        return SYWebsiteStatus_Timeout;
    }
    else if (!self.error && self.statusCode == 0)
    {
        return SYWebsiteStatus_Unknown;
    }
    return SYWebsiteStatus_Error;
}

@end

