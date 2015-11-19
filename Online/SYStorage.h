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

@property (nonatomic, copy) void(^websitesUpdatedBlock)(void);
@property (nonatomic, copy) void(^colorSettingsChanged)(void);

@property (nonatomic) NSColor *colorSuccess;
@property (nonatomic) NSColor *colorTimeout;
@property (nonatomic) NSColor *colorFailure;
@property (nonatomic, readonly) NSColor *defaultColorSuccess;
@property (nonatomic, readonly) NSColor *defaultColorTimeout;
@property (nonatomic, readonly) NSColor *defaultColorFailure;

+ (SYStorage *)shared;

- (void)addWebsite:(SYWebsiteModel *)website;
- (void)removeWebsite:(SYWebsiteModel *)website;
- (NSArray <SYWebsiteModel *> *)websites;
- (NSArray <SYProxyModel *> *)proxies;
- (SYWebsiteModel *)websiteForId:(NSString *)identifier;


@end
