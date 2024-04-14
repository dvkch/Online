//
//  ColorView.swift
//  Online
//
//  Created by syan on 14/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa

class ColorView: NSColorWell {
    
    // MARK: Init
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        if #available(macOS 13.0, *) {
            colorWellStyle = .minimal
        }
    }

    // MARK: Properties
    override var color: NSColor {
        get { super.color }
        set {
            super.color = newValue.usingColorSpace(.deviceRGB) ?? newValue
        }
    }
    
    override var intrinsicContentSize: NSSize {
        return .init(width: 16, height: 16)
    }
    
    override func sizeThatFits(_ size: NSSize) -> NSSize {
        return intrinsicContentSize
    }
    
    override var frame: NSRect {
        get { .init(origin: super.frame.origin, size: intrinsicContentSize) }
        set { super.frame = .init(origin: newValue.origin, size: intrinsicContentSize) }
    }
    
    override var bounds: NSRect {
        get { .init(origin: super.bounds.origin, size: intrinsicContentSize) }
        set { super.bounds = .init(origin: newValue.origin, size: intrinsicContentSize) }
    }
    
    // MARK: Content
    override func draw(_ dirtyRect: NSRect) {
        //super.draw(dirtyRect)

        // Width: 1px for 12 x 12 view
        let lineWidth: CGFloat = 1 * bounds.size.width / 12
        
        NSColor.clear.set()
        NSBezierPath.fill(dirtyRect)
        
        let rect = NSRectFromCGRect(CGRectInset(NSRectToCGRect(bounds), lineWidth, lineWidth))
        let circlePath = NSBezierPath(roundedRect: rect, xRadius: bounds.size.width / 2, yRadius: bounds.size.height / 2)
        circlePath.lineWidth = 1
        
        color.set()
        circlePath.fill()
        
        color.darken(by: 0.1).set()
        circlePath.stroke()

        if window?.firstResponder == self {
            NSGraphicsContext.saveGraphicsState()
            defer { NSGraphicsContext.restoreGraphicsState() }

            NSColor.keyboardFocusIndicatorColor.set()
            NSFocusRingPlacement.only.set()
            NSBezierPath(ovalIn: bounds).fill()
        }
    }
    
    // MARK: Helpers
    private func screenshot() -> NSImage {
        return NSImage(data: dataWithPDF(inside: bounds))!
    }
    
    static func screenshot(for color: NSColor, size: NSSize) -> NSImage {
        let view = ColorView(frame: .init(origin: .zero, size: size))
        view.color = color
        return view.screenshot()
    }
}
