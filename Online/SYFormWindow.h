//
//  SYFormWindow.h
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SYWebsiteModel.h"

@interface SYFormWindow : NSWindow

@property (nonatomic, strong) SYWebsiteModel *website;

+ (SYFormWindow *)windowForWebsite:(SYWebsiteModel *)website;

@end
