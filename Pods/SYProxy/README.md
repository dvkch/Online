SYProxy
=======

NSURLProtocol subclass to implement in-app proxying.

For a quick introduction to this pod take a look at the example project in this repo. 


```
/**
 *  Represents a proxy
 */
@interface SYProxyModel : NSObject <NSCoding, NSSecureCoding>

/**
 *  To uniquely identify an object. This string is autmatically generated when calling `-init`, and 
 *  again when calling `copy`
 */
@property (nonatomic, strong, readonly) NSString *identifier;

/**
 *  Proxy host name or address
 */
@property (nonatomic, strong) NSString *host;

/**
 *  Proxy port
 */
@property (nonatomic, assign) int port;

/**
 *  Proxy username if any
 */
@property (nonatomic, strong) NSString *username;

/**
 *  Proxy password if any
 */
@property (nonatomic, strong) NSString *password;

/**
 *  Array of wildcard rules. They will be used to determine if given URLs are eligible for this proxy
 */
@property (nonatomic, strong) NSArray <NSString *> *urlWildcardRules;

/**
 *  Creates a new proxy object with the given host and port
 *
 *  @param host proxy host name or address
 *  @param port proxy port
 *
 *  @return new proxy object
 */
- (instancetype)initWithHost:(NSString *)host port:(int)port;

/**
 *  Determines if a proxy is able to work for the given URL. It will iterate through the list
 *  of `urlWildcardRules` to determine if the URL matches the user criteria.
 *
 *  @param url url
 *
 *  @return `YES` if the receiver can be used for the given URL, otherwise `NO`
 */
- (BOOL)isValidForURL:(NSURL *)url;

/**
 *  Returns a copy of the receiver. The `identifier` property will be a new one.
 *  @return copy of the receiver
 */
- (id)copy;

/**
 *  Helper method to determine the first proxy available for a given url. It will go through all
 *  the given proxies and use the method `-isValidForURL:` to determine if the current proxy
 *  can be used for this URL.
 *
 *  @param proxies Array of `SYProxyModel` objects
 *  @param url     url
 *
 *  @return first proxy available for the given URL if any found, otherwise `nil`
 */
+ (SYProxyModel *)firstProxyInProxies:(NSArray <SYProxyModel *> *)proxies matchingURL:(NSURL *)url;

@end
```
    

```    
@protocol SYProxyURLProtocolDataSource <NSObject>

- (SYProxyModel *)firstProxyMatchingURL:(NSURL *)url;

@end

@interface SYProxyURLProtocol : NSURLProtocol

+ (void)setDataSource:(id<SYProxyURLProtocolDataSource>)dataSource;

@end
```


License
===

Use it as you like in every project you want, redistribute with mentions of my name and don't blame me if it breaks :)

-- dvkch
 
