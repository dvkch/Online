//
//  SYProxyURLProtocol.h
//  Proxy
//
//  Created by Stanislas Chevallier on 02/06/15.
//  Copyright (c) 2015 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  http://eng.kifi.com/customizing-uiwebview-requests-with-nsurlprotocol/
 *  http://stackoverflow.com/questions/16847858/ios-any-body-knows-how-to-add-a-proxy-to-nsurlrequest
 */

@class SYProxyURLProtocol;
@class SYProxyModel;

@protocol SYProxyURLProtocolDataSource <NSObject>
- (SYProxyModel *)firstProxyMatchingURL:(NSURL *)url;
@end

@interface SYProxyURLProtocol : NSURLProtocol

+ (void)setDataSource:(id<SYProxyURLProtocolDataSource>)dataSource;

@end
