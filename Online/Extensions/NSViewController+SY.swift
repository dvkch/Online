//
//  NSViewController+SY.swift
//  Online
//
//  Created by syan on 14/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa

extension NSViewController {
    static func nibViewController() -> Self {
        let nibName = String(describing: self).split(separator: ".").last!
        let nib = NSNib(nibNamed: String(nibName), bundle: nil)!

        var items: NSArray?
        nib.instantiate(withOwner: nil, topLevelObjects: &items)

        return (items ?? []).compactMap { $0 as? Self }.first!
    }

    func close() {
        view.window?.close()
    }
}
