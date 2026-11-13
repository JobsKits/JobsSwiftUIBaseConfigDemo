//
//  AppPreferences.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月12日，星期四.
//

import SwiftUI

final class AppPreferences: ObservableObject {

    static let shared = AppPreferences()
    static let languageKey = "com.jobs.swiftui.language"
    static let appearanceKey = "com.jobs.swiftui.debugPanel.demoAppearance"

    @Published var language: String {
        didSet {
            UserDefaults.standard.set(language, forKey: Self.languageKey)
        }
    }
    @Published var appearance: String {
        didSet {
            UserDefaults.standard.set(appearance, forKey: Self.appearanceKey)
        }
    }

    private init() {
        language = UserDefaults.standard.string(forKey: Self.languageKey) ?? "system"
        appearance = UserDefaults.standard.string(forKey: Self.appearanceKey) ?? "system"
    }

    var languageCode: String {
        if language != "system", Self.languages.contains(where: { $0.code == language }) {
            return language
        }
        return Self.normalized(Locale.preferredLanguages.first ?? "en")
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        /// Keep the system appearance live rather than resolving it once.
        case "light":
            return .light
        /// A manual dark choice applies to every scene.
        case "dark":
            return .dark
        /// Unknown saved values also follow the system.
        default:
            return nil
        }
    }

    static let languages: [(code: String, name: String)] = [
        ("zh-Hans", "简体中文"), ("zh-Hant", "繁體中文"), ("bo", "བོད་ཡིག"),
        ("en", "English"), ("ja", "日本語"), ("fr", "Français"),
        ("es", "Español"), ("de", "Deutsch"), ("ru", "Русский"), ("ko", "한국어")
    ]

    static func normalized(_ code: String) -> String {
        if code.hasPrefix("zh") {
            return code.contains("Hant") || code.contains("TW") || code.contains("HK") ? "zh-Hant" : "zh-Hans"
        }
        return languages.first(where: { code.hasPrefix($0.code) })?.code ?? "en"
    }
}
