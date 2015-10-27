//
//  SYCrawler.h
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYWebsiteModel.h"
#import "SYCrawlerResult.h"

@interface SYCrawler : NSObject

@property (atomic, copy) void(^resultChangedBlock)(void);

+ (SYCrawler *)shared;

- (SYCrawlerResult *)resultForWebsite:(NSString *)websiteID;
- (NSArray <SYCrawlerResult *> *)allResults;

@end
