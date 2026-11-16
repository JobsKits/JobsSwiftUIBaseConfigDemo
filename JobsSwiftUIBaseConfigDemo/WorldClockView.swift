//
//  WorldClockView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import SwiftUI

struct WorldClockView: View {

    @ObservedObject private var preferences = AppPreferences.shared
    @StateObject private var clock = JobsSwiftUIClock()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    @State private var visible = false

    var body: some View {
        let entries = WorldClockCatalog.entries(at: clock.now)
        List {
            Section {
                Toggle(AppText.text(preferences.worldClock12Hour ? "12小时制" : "24小时制"), isOn: $preferences.worldClock12Hour)
                    .accessibilityIdentifier("jobs.worldClock.twelveHour")
            }
            Section {
                currentClockCard(WorldClockCatalog.localEntry(at: clock.now))
                    .accessibilityIdentifier("jobs.worldClock.local")
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
            }
            Section {
                ForEach(entries) { entry in
                    clockRow(entry)
                        .accessibilityIdentifier("jobs.worldClock.\(entry.id)")
                }
            } header: {
                Text(AppText.text("世界时区"))
                    .foregroundStyle(Color.primary.opacity(0.7))
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView {
                    Label(AppText.text("没有可用时区"), systemImage: "clock")
                } description: {
                    Text(AppText.text("请重新加载系统时区数据。"))
                } actions: {
                    Button(AppText.text("重新加载"), action: clock.refresh)
                }
            }
        }
        .refreshable {
            clock.refresh()
        }
        .navigationTitle(AppText.text("世界时钟"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("jobs.worldClock.page")
        .onAppear {
            visible = true
            clock.setActive(scenePhase == .active)
        }
        .onDisappear {
            visible = false
            clock.setActive(false)
        }
        .onChange(of: scenePhase) { _, phase in
            clock.setActive(visible && phase == .active)
        }
    }

    private func currentClockCard(_ entry: WorldClockCatalog.Entry) -> some View {
        let foreground = colorScheme == .dark
            ? Color(red: 212 / 255, green: 1, blue: 241 / 255)
            : Color(red: 0, green: 77 / 255, blue: 64 / 255)
        let secondary = colorScheme == .dark
            ? Color(red: 170 / 255, green: 219 / 255, blue: 201 / 255)
            : Color(red: 21 / 255, green: 99 / 255, blue: 82 / 255)
        let background = colorScheme == .dark
            ? Color(red: 14 / 255, green: 61 / 255, blue: 51 / 255)
            : Color(red: 137 / 255, green: 249 / 255, blue: 218 / 255)
        return VStack(alignment: .leading, spacing: 0) {
            Text(AppText.text("当前时区"))
                .font(.title3)
                .padding(.bottom, 4)
            Text("\(WorldClockText.city(at: clock.now, zone: entry.timeZone, locale: locale)) · \(entry.offsetLabel)\n\(entry.id)")
                .font(.subheadline)
                .foregroundStyle(secondary)
                .textSelection(.enabled)
            Text(WorldClockText.time(at: clock.now, zone: entry.timeZone, twelveHour: preferences.worldClock12Hour))
                .font(.system(.largeTitle, design: .monospaced, weight: .regular))
                .padding(.top, 18)
                .padding(.bottom, 8)
            Text(WorldClockText.calendarDate(at: clock.now, zone: entry.timeZone, locale: locale))
                .font(.subheadline)
                .foregroundStyle(secondary)
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(background, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func clockRow(_ entry: WorldClockCatalog.Entry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.id == "Etc/GMT+12"
                 ? AppText.text("贝克岛（无人常住）")
                 : WorldClockText.city(at: clock.now, zone: entry.timeZone, locale: locale))
                .font(.headline)
                .foregroundStyle(.primary)
            Text("\(entry.timeZone.identifier) · \(entry.offsetLabel)")
                .font(.subheadline)
                .foregroundStyle(Color.primary.opacity(0.7))
                .textSelection(.enabled)
            Text(WorldClockText.calendarDate(at: clock.now, zone: entry.timeZone, locale: locale))
                .font(.subheadline)
                .foregroundStyle(Color.primary.opacity(0.7))
            Text(WorldClockText.time(at: clock.now, zone: entry.timeZone, twelveHour: preferences.worldClock12Hour))
                .font(.system(.title2, design: .monospaced, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
