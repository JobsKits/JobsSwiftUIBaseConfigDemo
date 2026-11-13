//
//  AppSettingsView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月12日，星期四.
//

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject private var preferences: AppPreferences

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(AppText.text("语言"), selection: $preferences.language) {
                        Text(AppText.text("跟随系统")).tag("system")
                        ForEach(AppPreferences.languages, id: \.code) { language in
                            Text(language.name).tag(language.code)
                        }
                    }
                    .accessibilityIdentifier("jobs.settings.language")
                } header: {
                    Text(AppText.text("语言"))
                } footer: {
                    Text(AppText.text("语言设置对整个 App 生效，所有 Demo 共用此设置。"))
                }

                Section(AppText.text("外观")) {
                    Picker(AppText.text("主题"), selection: $preferences.appearance) {
                        Text(AppText.text("跟随系统")).tag("system")
                        Text(AppText.text("白天")).tag("light")
                        Text(AppText.text("黑夜")).tag("dark")
                    }
                    .accessibilityIdentifier("jobs.settings.appearance")
                }
            }
            .navigationTitle(AppText.text("设置"))
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .inline : .large)
        }
    }
}
