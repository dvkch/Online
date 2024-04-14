//
//  SettingsViewController.swift
//  Online
//
//  Created by syan on 14/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    // MARK: NSViewController
    override func viewWillAppear() {
        super.viewWillAppear()
        readColors()
    }
    
    // MARK: Views
    @IBOutlet private var pickerSuccess: ColorView!
    @IBOutlet private var pickerTimeout: ColorView!
    @IBOutlet private var pickerFailure: ColorView!
    
    // MARK: Action
    @IBAction private func pickerDidChangeColor(sender: Any) {
        writeColors()
    }
    
    @IBAction private func buttonDefaultsTap(sender: Any) {
        Storage.shared.colorSuccess = Storage.shared.defaultColorSuccess
        Storage.shared.colorTimeout = Storage.shared.defaultColorTimeout
        Storage.shared.colorFailure = Storage.shared.defaultColorFailure
        readColors()
    }
    
    @IBAction private func buttonCloseTap(sender: Any) {
        close()
    }
    
    // MARK: Content
    private func writeColors() {
        Storage.shared.colorSuccess = pickerSuccess.color
        Storage.shared.colorTimeout = pickerTimeout.color
        Storage.shared.colorFailure = pickerFailure.color
    }

    private func readColors() {
        pickerSuccess.color = Storage.shared.colorSuccess
        pickerTimeout.color = Storage.shared.colorTimeout
        pickerFailure.color = Storage.shared.colorFailure
    }
}
