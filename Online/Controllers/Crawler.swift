//
//  Crawler.swift
//  Online
//
//  Created by syan on 13/04/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

protocol CrawlerDelegate: NSObjectProtocol {
    func crawlerResultsChanged(_ crawler: Crawler)
}

class Crawler {
    
    // MARK: Init
    static let shared = Crawler()
    private init() {
        restartAll()
    }
    
    // MARK: Properties
    weak var delegate: CrawlerDelegate?
    var websites: [Website] = [] {
        didSet {
            restartAll()
        }
    }
    private(set) var statuses: [String: WebsiteStatus] = [:]
    private var timers: [Timer] = []
    private let urlSession = URLSession(configuration: .default)
    
    // MARK: Internal methods
    private func restartAll() {
        timers.forEach { $0.invalidate() }
        timers = []
        
        websites.forEach { website in
            crawl(websiteID: website.identifier)
        }
    }
    
    private func crawl(websiteID: String) {
        guard let website = websites.first(where: { $0.identifier == websiteID }), let url = URL(string: website.url) else {
            statuses[websiteID] = nil
            return
        }

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: website.timeout)
        let task = urlSession.dataTask(with: request) { data, response, error in
            let status = WebsiteStatus(httpStatus: (response as? HTTPURLResponse)?.statusCode, error: error)
            self.statuses[websiteID] = status

            let timeBeforeNextUpdate = status.isOn ? website.timeBeforeRetryIfSuccessed : website.timeBeforeRetryIfFailed
            let timer = Timer(timeInterval: timeBeforeNextUpdate, target: self, selector: #selector(self.timerTick), userInfo: ["websiteID": websiteID], repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            self.timers.append(timer)

            DispatchQueue.main.async {
                self.delegate?.crawlerResultsChanged(self)
            }
        }
        task.resume()
    }
    
    @objc private func timerTick(_ timer: Timer) {
        defer {
            timer.invalidate()
            timers.removeAll(where: { $0 == timer })
        }

        guard let userInfo = timer.userInfo as? [String: String], let websiteID = userInfo["websiteID"] else {
            print("Unknown timer fired, userInfo was: \(timer.userInfo ?? [:])")
            return
        }
        
        crawl(websiteID: websiteID)
    }
}
