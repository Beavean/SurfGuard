//
//  WebPageManager.swift
//  WebsiteFilter
//
//  Created by Beavean on 24.02.2023.
//

import Foundation

final class WebBrowserManager {
    private static let userDefaults = UserDefaults.standard
    static var addedFilters: [String] {
        get { userDefaults.object(forKey: #function) as? [String] ?? [] }
        set { userDefaults.set(newValue, forKey: #function) }
    }

    static var lastOpenedPage: String? {
        get { userDefaults.object(forKey: #function) as? String }
        set { userDefaults.set(newValue, forKey: #function) }
    }

    func createUrl(from string: String) -> URL? {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        guard trimmedString.count >= 2 else { return nil }
        var urlString = trimmedString
        if !trimmedString.lowercased().hasPrefix("http://") && !trimmedString.lowercased().hasPrefix("https://") {
            if trimmedString.contains(".") {
                urlString = "https://" + trimmedString
            } else {
                guard let searchQuery = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                else { return nil }
                urlString = "https://google.com/search?q=" + searchQuery
            }
        }
        return URL(string: urlString)
    }

    func isUrlBlocked(urlString: String) -> Bool {
        let addedFilters = WebBrowserManager.addedFilters
        let filterComponents = addedFilters.flatMap { $0.components(separatedBy: " ") }
        let isBlocked = filterComponents.contains { urlString.contains($0.lowercased()) }
        return isBlocked
    }
}
