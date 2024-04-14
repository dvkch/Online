//
//  WebsiteStatus.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import Cocoa

enum WebsiteStatus {
    case on(httpStatus: Int)
    case timeout
    case error(Error)
    case unknown
    
    init(httpStatus: Int?, error: Error?) {
        if let httpStatus, httpStatus > 0 {
            self = .on(httpStatus: httpStatus)
        }
        else if let e = (error as? NSError), e.domain == NSURLErrorDomain, e.code == NSURLErrorTimedOut {
            self = .timeout
        }
        else if let error {
            self = .error(error)
        }
        else {
            self = .unknown
        }
    }
}

extension WebsiteStatus {
    var isOn: Bool {
        if case .on = self {
            return true
        }
        return false
    }
    
    var isTimeout: Bool {
        if case .timeout = self {
            return true
        }
        return false
    }
    
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
    
    var isUnknown: Bool {
        if case .unknown = self {
            return true
        }
        return false
    }
    
    var image: NSImage {
        let color: NSColor
        switch self {
        case .on:       color = Storage.shared.colorSuccess
        case .timeout:  color = Storage.shared.colorTimeout
        case .error:    color = Storage.shared.colorFailure
        case .unknown:  color = NSColor(calibratedWhite: 0.6, alpha: 1)
        }
        return ColorView.screenshot(for: color, size: NSSize(width: 12, height: 12))
    }
    
    var message: String {
        switch self {
        case .on(let httpStatus):   return "HTTP \(httpStatus)"
        case .timeout:              return "Timeout"
        case .error(let error):     return error.localizedDescription
        case .unknown:              return "Unknown"
        }
    }
}
