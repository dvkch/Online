//
//  Website.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import SYProxy

@objc(SYWebsiteModel)
class Website: NSObject, NSCoding, NSSecureCoding {
    
    // MARK: Init
    override init() {
        self.identifier = UUID().uuidString
        super.init()
    }
    
    // MARK: NSCoding
    required init(coder: NSCoder) {
        identifier                  = coder.decodeObject(of: NSString.self, forKey: "identifier")! as String
        name                        = coder.decodeObject(of: NSString.self, forKey: "name")! as String
        url                         = coder.decodeObject(of: NSString.self, forKey: "url")! as String
        timeout                     = coder.decodeDouble(forKey: "timeout")
        timeBeforeRetryIfFailed     = coder.decodeDouble(forKey: "timeBeforeRetryIfFailed")
        timeBeforeRetryIfSuccessed  = coder.decodeDouble(forKey: "timeBeforeRetryIfSuccessed")
        proxy                       = coder.decodeObject(of: Proxy.self, forKey: "proxy")!
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(identifier,                    forKey: "identifier")
        coder.encode(name,                          forKey: "name")
        coder.encode(url,                           forKey: "url")
        coder.encode(timeout,                       forKey: "timeout")
        coder.encode(timeBeforeRetryIfFailed,       forKey: "timeBeforeRetryIfFailed")
        coder.encode(timeBeforeRetryIfSuccessed,    forKey: "timeBeforeRetryIfSuccessed")
        coder.encode(proxy,                         forKey: "proxy")
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: Properties
    let identifier: String
    var name: String = ""
    var url: String = ""
    var timeout: TimeInterval = 10
    var timeBeforeRetryIfFailed: TimeInterval = 10
    var timeBeforeRetryIfSuccessed: TimeInterval = 10
    var proxy: Proxy = .init(host: "", port: 0)
    
    // MARK: Equality
    override var hash: Int {
        return identifier.hash
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return (object as? Website)?.identifier == identifier
    }
}
