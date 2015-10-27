//
//  SYWebsiteModel.h
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SYProxy.h"

@interface SYWebsiteModel : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, assign) NSTimeInterval timeBeforeRetryIfFailed;
@property (nonatomic, assign) NSTimeInterval timeBeforeRetryIfSuccessed;
@property (nonatomic, strong) SYProxyModel *proxy;

@end
