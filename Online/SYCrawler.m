//
//  SYCrawler.m
//  Online
//
//  Created by Stan Chevallier on 27/10/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYCrawler.h"
#import "SYStorage.h"

@interface SYCrawler ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, SYCrawlerResult *> *results;
@end

@implementation SYCrawler

+ (SYCrawler *)shared
{
    static dispatch_once_t onceToken;
    static SYCrawler *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SYCrawler alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.results = [NSMutableDictionary dictionary];
        
        // start saved items
        for (SYWebsiteModel *website in [[SYStorage shared] websites])
            [self updateStatusForWebsiteWithID:website.identifier];
        
        // start new items
        [[SYStorage shared] setWebsiteAddedBlock:^(SYWebsiteModel *website) {
            [self updateStatusForWebsiteWithID:website.identifier];
        }];
    }
    return self;
}

- (void)setResultWithStatusCode:(NSInteger)statusCode andError:(NSError *)error forWebsite:(NSString *)websiteID
{
    [self.results setObject:[[SYCrawlerResult alloc] initWithStatusCode:statusCode andError:error] forKey:websiteID];
    if (self.resultChangedBlock)
        self.resultChangedBlock();
}

- (void)removeResultForWebsite:(NSString *)websiteID
{
    [self.results removeObjectForKey:websiteID];
    if (self.resultChangedBlock)
        self.resultChangedBlock();
}

- (SYCrawlerResult *)resultForWebsite:(NSString *)websiteID
{
    return self.results[websiteID];
}

- (NSArray <SYCrawlerResult *> *)allResults
{
    return [self.results allValues];
}

- (void)updateStatusForWebsiteWithID:(NSString *)websiteID
{
    if ([self.results objectForKey:websiteID])
        return;
    
    SYWebsiteModel *website = [[SYStorage shared] websiteForId:websiteID];
    
    // removed from storage
    if (!website)
    {
        [self.results removeObjectForKey:websiteID];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:website.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
        NSHTTPURLResponse *response;
        NSError *error;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setResultWithStatusCode:response.statusCode andError:error forWebsite:websiteID];
            
            NSTimeInterval timeBeforeNextUpdate = (response.statusCode == 200) ? website.timeBeforeRetryIfSuccessed : website.timeBeforeRetryIfFailed;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeBeforeNextUpdate * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateStatusForWebsiteWithID:websiteID];
            });
        });
    });
}

@end

