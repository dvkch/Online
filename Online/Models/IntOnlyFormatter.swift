//
//  IntOnlyFormatter.swift
//  Online
//
//  Created by syan on 14/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import AppKit

class IntOnlyFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {
            return true
        }
        
        let scanner = Scanner(string: partialString)
        if !scanner.scanInt(nil) && scanner.isAtEnd {
            __NSBeep()
            return false
        }
        return true
    }
}
