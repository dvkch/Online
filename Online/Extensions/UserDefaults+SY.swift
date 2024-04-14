//
//  UserDefaults+SY.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

extension UserDefaults {
    func nsCodingValues<T: NSObject & NSSecureCoding>(_ type: T.Type, forKey key: String) -> [T]? {
        guard let data = data(forKey: key) else { return nil }
        do {
            if #available(macOS 11.0, *) {
                return try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: type, from: data)
            } else {
                let items: [T] = try NSKeyedUnarchiver.unarchivedObject(ofClasses: .init([NSArray.self, type]), from: data) as! [T]
                return items
            }
        }
        catch {
            print("Couldn't decode values for key \(key): \(error)")
            return nil
        }
    }

    func nsCodingValue<T: NSObject & NSSecureCoding>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: type, from: data)
        }
        catch {
            print("Couldn't decode value for key \(key): \(error)")
            return nil
        }
    }

    func set<T: NSObject & NSSecureCoding>(nsCodingValue: T, forKey key: String) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: nsCodingValue, requiringSecureCoding: false)
            set(data, forKey: key)
        }
        catch {
            print("Couldn't encode value for key \(key): \(error)")
        }
    }

    func set<T: NSObject & NSSecureCoding>(nsCodingValues: [T], forKey key: String) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: nsCodingValues, requiringSecureCoding: false)
            set(data, forKey: key)
        }
        catch {
            print("Couldn't encode values for key \(key): \(error)")
        }
    }
}
