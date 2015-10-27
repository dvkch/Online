//
//  SYStorage.h
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYWebsiteModel.h"

@interface SYStorage : NSObject

@property (nonatomic, copy) void(^websiteAddedBlock)(SYWebsiteModel *website);

+ (SYStorage *)shared;

- (void)addWebsite:(SYWebsiteModel *)website;
- (void)removeWebsite:(SYWebsiteModel *)website;
- (NSArray <SYWebsiteModel *> *)websites;
- (NSArray <SYProxyModel *> *)proxies;
- (SYWebsiteModel *)websiteForId:(NSString *)identifier;

@end
