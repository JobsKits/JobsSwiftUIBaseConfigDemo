//
//  AppText.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月12日，星期四.
//

import Foundation

enum AppText {

    private static let catalog: [String: [String: String]] = {
        guard let url = Bundle.main.url(forResource: "AppText", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let values = try? JSONSerialization.jsonObject(with: data) as? [String: [String: String]] else {
            return [:]
        }
        return values
    }()

    static func text(_ key: String) -> String {
        let language = AppPreferences.shared.languageCode
        return catalog[language]?[key] ?? catalog["en"]?[key] ?? key
    }

    static func format(_ key: String, _ values: String...) -> String {
        return String(format: text(key), arguments: values)
    }
}
