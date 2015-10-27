//
//  SYCrawlerResult.h
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SYWebsiteStatus_Unknown,
    SYWebsiteStatus_On,
    SYWebsiteStatus_Timeout,
    SYWebsiteStatus_Error,
} SYWebsiteStatus;

@interface SYCrawlerResult : NSObject

@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSInteger statusCode;

- (instancetype)initWithStatusCode:(NSInteger)statusCode andError:(NSError *)error;

- (NSString *)detailedString;

- (SYWebsiteStatus)status;

@end

