//
//  Storage.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import Cocoa
import SYProxy

protocol StorageDelegate: NSObjectProtocol {
    func storageWebsitesChanged(_ storage: Storage)
    func storageColorsChanged(_ storage: Storage)
}

class Storage {
    
    // MARK: Init
    static let shared = Storage()
    private init() {
        websites = UserDefaults.standard.nsCodingValues(Website.self, forKey: "websites") ?? []
    }
    
    // MARK: Properties
    weak var delegate: StorageDelegate?
    
    // MARK: Colors
    var colorSuccess: NSColor {
        get { UserDefaults.standard.nsCodingValue(NSColor.self, forKey: "colorSuccess") ?? defaultColorSuccess }
        set { UserDefaults.standard.set(nsCodingValue: newValue, forKey: "colorSuccess"); delegate?.storageColorsChanged(self) }
    }
    var colorTimeout: NSColor {
        get { UserDefaults.standard.nsCodingValue(NSColor.self, forKey: "colorTimeout") ?? defaultColorTimeout }
        set { UserDefaults.standard.set(nsCodingValue: newValue, forKey: "colorTimeout"); delegate?.storageColorsChanged(self) }
    }
    var colorFailure: NSColor {
        get { UserDefaults.standard.nsCodingValue(NSColor.self, forKey: "colorFailure") ?? defaultColorFailure }
        set { UserDefaults.standard.set(nsCodingValue: newValue, forKey: "colorFailure"); delegate?.storageColorsChanged(self) }
    }
    let defaultColorSuccess: NSColor = .init(calibratedRed: 0, green: 0.82, blue: 0.32, alpha: 1)
    let defaultColorTimeout: NSColor = .init(calibratedRed: 1, green: 0.75, blue: 0.29, alpha: 1)
    let defaultColorFailure: NSColor = .init(calibratedRed: 1, green: 0.34, blue: 0.37, alpha: 1)
    
    // MARK: Websites
    private(set) var websites: [Website] {
        didSet {
            UserDefaults.standard.set(nsCodingValues: websites, forKey: "websites")
            delegate?.storageWebsitesChanged(self)
        }
    }

    func addWebsite(_ website: Website) {
        if let index = websites.firstIndex(where: { $0.identifier == website.identifier }) {
            websites.replaceSubrange(index..<(index + 1), with: [website])
        }
        else {
            websites.append(website)
        }
    }

    func removeWebsite(_ website: Website) {
        websites.removeAll(where: { $0.identifier == website.identifier })
    }

    func website(for id: String) -> Website? {
        return websites.first(where: { $0.identifier == id })
    }

    var proxies: [Proxy] {
        return websites.map(\.proxy)
    }
}
