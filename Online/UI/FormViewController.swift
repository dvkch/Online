//
//  FormViewController.swift
//  Online
//
//  Created by syan on 14/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa

class FormViewController: NSViewController {
    
    // MARK: Init
    static func viewController(website: Website?) -> Self {
        let vc = self.nibViewController()
        vc.website = website
        return vc
    }

    // MARK: NSViewController
    override func viewWillAppear() {
        super.viewWillAppear()
        fieldProxyPort.formatter = IntOnlyFormatter()
        fieldTimeout.formatter = IntOnlyFormatter()
        fieldTimeBeforeRetryIfSuccess.formatter = IntOnlyFormatter()
        fieldTimeBeforeRetryIfFailed.formatter = IntOnlyFormatter()

        updateContent()
    }

    // MARK: Property
    private(set) var website: Website?
    
    // MARK: Views
    @IBOutlet private var fieldName: NSTextField!
    @IBOutlet private var fieldURL: NSTextField!
    @IBOutlet private var fieldProxyHost: NSTextField!
    @IBOutlet private var fieldProxyPort: NSTextField!
    @IBOutlet private var fieldProxyUser: NSTextField!
    @IBOutlet private var fieldProxyPass: NSTextField!
    @IBOutlet private var fieldTimeout: NSTextField!
    @IBOutlet private var fieldTimeBeforeRetryIfSuccess: NSTextField!
    @IBOutlet private var fieldTimeBeforeRetryIfFailed: NSTextField!
    @IBOutlet private var buttonCancel: NSButton!
    @IBOutlet private var containerView: NSView!
    
    // MARK: Actions
    @IBAction private func saveButtonTap(sender: Any) {
        guard validationErrors().isEmpty else {
            let alert = NSAlert()
            alert.messageText = "Invalid configuration"
            alert.informativeText = "The following errors have been found:" + validationErrors().map { "\n- " + $0 }.joined()
            alert.addButton(withTitle: "Close")
            alert.beginSheetModal(for: view.window!, completionHandler: nil)
            return
        }
        
        let website = self.website ?? .init()
        website.name                        = fieldName.stringValue
        website.url                         = fieldURL.stringValue
        website.proxy.host                  = fieldProxyHost.stringValue
        website.proxy.port                  = UInt16(clamping: fieldProxyPort.intValue)
        website.proxy.username              = fieldProxyUser.stringValue
        website.proxy.password              = fieldProxyPass.stringValue
        website.proxy.urlWildcardRules      = [website.url]
        website.timeout                     = fieldTimeout.doubleValue
        website.timeBeforeRetryIfSuccessed  = fieldTimeBeforeRetryIfSuccess.doubleValue
        website.timeBeforeRetryIfFailed     = fieldTimeBeforeRetryIfFailed.doubleValue
        
        Storage.shared.addWebsite(website)
        close()
    }
    
    @IBAction private func cancelButtonTap(sender: Any) {
        close()
    }
    
    // MARK: Content
    private func updateContent() {
        if website != nil {
            title = "Edit website"
        }
        else {
            title = "New website"
        }
        
        fieldName.stringValue   = website?.name ?? ""
        fieldURL.stringValue    = website?.url ?? ""

        fieldProxyHost.stringValue  = website?.proxy.host ?? ""
        fieldProxyPort.intValue     = Int32(website?.proxy.port ?? 0)
        fieldProxyUser.stringValue  = website?.proxy.username ?? ""
        fieldProxyPass.stringValue  = website?.proxy.password ?? ""
        
        fieldTimeout.doubleValue                    = website?.timeout ?? 0
        fieldTimeBeforeRetryIfSuccess.doubleValue   = website?.timeBeforeRetryIfSuccessed ?? 0
        fieldTimeBeforeRetryIfFailed.doubleValue    = website?.timeBeforeRetryIfFailed ?? 0
    }
    
    private func validationErrors() -> [String] {
        var errors: [String] = []
        if fieldName.stringValue.isEmpty {
            errors.append("name must not be empty")
        }
        if URL(string: fieldURL.stringValue) == nil {
            errors.append("URL must be present and a valid url")
        }
        
        if fieldProxyHost.stringValue.isEmpty && fieldProxyPort.integerValue > 0 {
            errors.append("proxy port is set but not the host")
        }
        if fieldProxyHost.stringValue.count > 0 && fieldProxyPort.integerValue == 0 {
            errors.append("proxy port must not be 0 or empty")
        }
        if fieldProxyUser.stringValue.isEmpty && fieldProxyPass.stringValue.count > 0 {
            errors.append("proxy username cannot be empty if you provide a password")
        }
        if fieldProxyUser.stringValue.count > 0 && fieldProxyHost.stringValue.isEmpty {
            errors.append("proxy user is defined but not the host")
        }
        
        if fieldTimeout.doubleValue < 2 {
            errors.append("timeout must be greater than 2s")
        }
        if fieldTimeBeforeRetryIfSuccess.doubleValue < 5 || fieldTimeBeforeRetryIfFailed.doubleValue < 5 {
            errors.append("time between requests must be greater than or equal to 5s")
        }
        if (fieldTimeout.intValue % 5) != 0 || (fieldTimeBeforeRetryIfSuccess.intValue % 5) != 0 || (fieldTimeBeforeRetryIfFailed.intValue % 5) != 0 {
            errors.append("times must be multiples of 5")
        }
        
        return errors
    }
}
