//
//  AppDelegate.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Cocoa
import SYProxy

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: Properties
    @IBOutlet private var statusMenu: NSMenu!
    private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var popover: NSPopover?
    
    // MARK: AppDelegate
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusMenu.delegate = self
        statusItem.menu = statusMenu
        statusItem.image = WebsiteStatus.unknown.image
        statusItem.highlightMode = true
        
        Storage.shared.delegate = self

        Crawler.shared.websites = Storage.shared.websites
        Crawler.shared.delegate = self
        
        ProxyURLProtocol.register()
        ProxyURLProtocol.isLoggingEnabled = true
        ProxyURLProtocol.dataSource = self
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK: Images
    private func updateIcon() {
        let statuses = Array(Crawler.shared.statuses.values)
        let prominentStatus = statuses.first(where: \.isError) ?? statuses.first(where: \.isTimeout) ?? statuses.first(where: \.isOn) ?? WebsiteStatus.unknown
        statusItem.image = prominentStatus.image
        statusItem.menu?.items.forEach { item in
            if let websiteID = item.representedObject as? String {
                let status = Crawler.shared.statuses[websiteID] ?? .unknown
                item.image = status.image
            }
        }
    }
}

extension AppDelegate {
    private func openForm(for website: Website?) {
        let vc = FormViewController.viewController(website: website)
        openPopover(for: vc)
    }
    
    private func openSettings() {
        let vc = SettingsViewController.nibViewController()
        openPopover(for: vc)
    }

    private func openPopover(for viewController: NSViewController) {
        popover?.close()
        
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentViewController = viewController
        popover?.animates = false
        popover?.show(relativeTo: statusItem.button!.frame, of: statusItem.button!, preferredEdge: .minY)
        popover?.contentViewController?.view.window?.makeKeyAndOrderFront(NSApp)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension AppDelegate: StorageDelegate {
    func storageColorsChanged(_ storage: Storage) {
        updateIcon()
    }
    
    func storageWebsitesChanged(_ storage: Storage) {
        Crawler.shared.websites = storage.websites
    }
}

extension AppDelegate: CrawlerDelegate {
    func crawlerResultsChanged(_ crawler: Crawler) {
        updateIcon()
    }
}

extension AppDelegate: ProxyURLProtocolDataSource {
    func proxyURLProtocolRequiresFirstProxyMatching(url: URL) -> Proxy? {
        return Storage.shared.proxies.first(matching: url)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        popover?.close()
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard menu == statusMenu else { return }
        
        menu.removeAllItems()
        
        for website in Storage.shared.websites {
            let status = Crawler.shared.statuses[website.identifier] ?? .unknown
            
            let item = NSMenuItem(title: website.name, action: nil, keyEquivalent: "")
            item.image = status.image
            item.representedObject = website.identifier
            item.submenu = NSMenu()
            menu.addItem(item)
            
            addMenuItem(title: status.message, to: item.submenu!)
            addMenuItem(title: "Edit...", to: item.submenu!) {
                self.openForm(for: website)
            }
            addMenuItem(title: "Delete", to: item.submenu!) {
                let alert = NSAlert()
                alert.messageText = "Are you sure you want to delete \(website.name)?"
                alert.informativeText = "This operation cannot be undone."
                alert.addButton(withTitle: "Delete").keyEquivalent = ""
                alert.addButton(withTitle: "Cancel").keyEquivalent = "\r"
                if alert.runModal() == .alertFirstButtonReturn {
                    Storage.shared.removeWebsite(website)
                }
            }
        }
        
        menu.addItem(.separator())

        addMenuItem(title: "Add a new website...", to: menu) {
            self.openForm(for: nil)
        }
        
        addMenuItem(title: "Settings", to: menu) {
            self.openSettings()
        }
        
        addMenuItem(title: "Quit", to: menu) {
            NSApp.terminate(nil)
        }
    }
    
    private func addMenuItem(title: String, to menu: NSMenu, action: (() -> ())? = nil) {
        let item = NSMenuItem(title: title, action: #selector(self.menuTapped(item:)), keyEquivalent: "")
        item.target = self
        item.representedObject = action
        menu.addItem(item)
    }
    
    @objc private func menuTapped(item: NSMenuItem) {
        let action = item.representedObject as? () -> ()
        action?()
    }
}
