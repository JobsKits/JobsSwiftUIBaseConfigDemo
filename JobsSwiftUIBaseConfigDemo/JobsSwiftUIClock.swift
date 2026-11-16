//
//  JobsSwiftUIClock.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import Combine
import Foundation

/// SwiftUI 计时适配：沿用 JobsTimer 的幂等启停与代次隔离，界面决定可见生命周期。
@MainActor
final class JobsSwiftUIClock: ObservableObject {

    @Published private(set) var now = Date()
    private(set) var isRunning = false
    private var generation = 0
    private var subscriptions = Set<AnyCancellable>()

    func setActive(_ active: Bool) {
        guard active != isRunning else {
            return
        }
        generation += 1
        isRunning = active
        subscriptions.removeAll()
        guard active else {
            return
        }
        refresh()
        let token = generation
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isRunning, self.generation == token else {
                    return
                }
                self.refresh()
            }
            .store(in: &subscriptions)
        NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)
            .merge(with: NotificationCenter.default.publisher(for: .NSSystemClockDidChange))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self, self.isRunning, self.generation == token else {
                    return
                }
                self.refresh()
            }
            .store(in: &subscriptions)
    }

    func refresh() {
        now = Date()
    }
}

enum WorldClockText {

    static func city(at date: Date, zone: TimeZone, locale: Locale) -> String {
        date.formatted(Date.FormatStyle(timeZone: zone)
            .timeZone(.exemplarLocation)
            .locale(locale))
    }

    static func calendarDate(at date: Date, zone: TimeZone, locale: Locale) -> String {
        date.formatted(Date.FormatStyle(timeZone: zone)
            .year().month(.wide).day().weekday(.wide)
            .locale(locale))
    }

    static func time(at date: Date, zone: TimeZone, twelveHour: Bool = false) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let parts = calendar.dateComponents([.hour, .minute, .second], from: date)
        if twelveHour {
            let hour = parts.hour ?? 0
            return String(format: "%02d:%02d:%02d %@",
                          hour % 12 == 0 ? 12 : hour % 12,
                          parts.minute ?? 0,
                          parts.second ?? 0,
                          hour < 12 ? "AM" : "PM")
        }
        return String(format: "%02d:%02d:%02d", parts.hour ?? 0, parts.minute ?? 0, parts.second ?? 0)
    }
}
