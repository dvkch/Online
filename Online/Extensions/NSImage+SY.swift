//
//  NSImage+SY.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa

extension NSImage {
    convenience init(color: NSColor, size: NSSize = .init(width: 1, height: 1)) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }
}
