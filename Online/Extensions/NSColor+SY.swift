//
//  NSColor+SY.swift
//  Online
//
//  Created by syan on 14/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa

extension NSColor {
    func darken(by amount: Double) -> NSColor {
        return NSColor(
            calibratedRed: redComponent - amount,
            green: greenComponent - amount,
            blue: blueComponent - amount,
            alpha: alphaComponent
        )
    }
}
