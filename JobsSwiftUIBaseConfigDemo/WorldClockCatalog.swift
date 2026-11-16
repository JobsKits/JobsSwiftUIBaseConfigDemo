//
//  WorldClockCatalog.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import Foundation

enum WorldClockCatalog {

    struct Entry: Identifiable {

        let timeZone: TimeZone
        let offset: Int

        var id: String {
            timeZone.identifier
        }

        var offsetLabel: String {
            let magnitude = abs(offset)
            return String(format: "UTC%@%02d:%02d",
                          offset < 0 ? "−" : "+",
                          magnitude / 3600,
                          magnitude % 3600 / 60)
        }
    }

    /// 同一时刻按有效偏移分组；夏令时切换后代表与组数随系统数据库重算。
    static func entries(at date: Date,
                        identifiers: [String] = TimeZone.knownTimeZoneIdentifiers) -> [Entry] {
        var representatives: [Int: TimeZone] = [:]
        let rank = Dictionary(uniqueKeysWithValues: preferredIdentifiers.enumerated().map {
            ($0.element, $0.offset)
        })
        // Foundation 可解析部分 canonical IANA ID，却不一定在 knownIDs 中列出它们。
        let candidates = Set(identifiers + preferredIdentifiers + ["Etc/GMT+12"])
        for identifier in candidates.sorted() {
            guard let zone = TimeZone(identifier: identifier) else {
                continue
            }
            let offset = zone.secondsFromGMT(for: date)
            if let existing = representatives[offset],
               (rank[existing.identifier] ?? Int.max) <= (rank[identifier] ?? Int.max) {
                continue
            }
            representatives[offset] = zone
        }
        return representatives.keys.sorted().compactMap { offset in
            guard let zone = representatives[offset] else {
                return nil
            }
            return Entry(timeZone: zone,
                         offset: offset)
        }
    }

    static func localEntry(at date: Date,
                           timeZone: TimeZone = .autoupdatingCurrent) -> Entry {
        Entry(timeZone: timeZone,
              offset: timeZone.secondsFromGMT(for: date))
    }

    private static let preferredIdentifiers = [
        "Europe/Paris", "America/New_York", "Europe/London", "Asia/Shanghai",
        "Asia/Tokyo", "Australia/Sydney", "Pacific/Auckland", "America/Los_Angeles",
        "America/Chicago", "America/Denver", "Asia/Dubai", "Asia/Kolkata",
        "Asia/Kathmandu", "Asia/Karachi", "Asia/Dhaka", "Asia/Yangon", "Asia/Bangkok",
        "Asia/Tehran", "Asia/Kabul", "Australia/Eucla", "Australia/Darwin",
        "Australia/Lord_Howe", "Pacific/Chatham", "Pacific/Honolulu", "Pacific/Marquesas",
        "Pacific/Gambier", "America/Anchorage", "America/Halifax", "America/St_Johns",
        "America/Sao_Paulo", "Atlantic/South_Georgia", "Atlantic/Azores", "Atlantic/Cape_Verde",
        "Africa/Cairo", "Europe/Moscow", "Pacific/Noumea", "Pacific/Norfolk",
        "Pacific/Tongatapu", "Pacific/Kiritimati", "Pacific/Pago_Pago"
    ]
}
