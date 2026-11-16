//
//  WorldClockTests.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import Foundation

@main
enum WorldClockTests {

    @MainActor
    static func main() throws {
        let winter = try date("2026-01-15T12:00:00Z")
        let summer = try date("2026-07-15T12:00:00Z")
        for now in [winter, summer] {
            let entries = WorldClockCatalog.entries(at: now)
            let offsets = entries.map(\.offset)
            let expected = Set((TimeZone.knownTimeZoneIdentifiers + ["Etc/GMT+12"]).compactMap(TimeZone.init(identifier:))
                .map { $0.secondsFromGMT(for: now) })
            expect(Set(offsets) == expected, "每个系统实际偏移都有代表")
            expect(Set(offsets).count == entries.count && offsets == offsets.sorted(), "偏移唯一且有序")
            expect(entries.contains(where: { $0.id == "Europe/Paris" }), "巴黎优先")
            expect(entries.contains(where: { $0.id == "America/New_York" }), "纽约优先")
            expect(entries.contains(where: { abs($0.offset) % 3600 == 1800 }), "半小时时区")
            expect(entries.contains(where: { abs($0.offset) % 3600 == 2700 }), "四十五分钟时区")
        }
        let ny = TimeZone(identifier: "America/New_York")!
        let paris = TimeZone(identifier: "Europe/Paris")!
        let beforeNY = try date("2026-03-08T06:59:59Z")
        let afterNY = try date("2026-03-08T07:00:00Z")
        expect(WorldClockText.time(at: beforeNY, zone: ny) == "01:59:59", "纽约夏令时前")
        expect(WorldClockText.time(at: afterNY, zone: ny) == "03:00:00", "纽约跳过不存在小时")
        expect(ny.secondsFromGMT(for: afterNY) - ny.secondsFromGMT(for: beforeNY) == 3600, "纽约有效偏移切换")
        let beforeParis = try date("2026-03-29T00:59:59Z")
        let afterParis = try date("2026-03-29T01:00:00Z")
        expect(WorldClockText.time(at: beforeParis, zone: paris) == "01:59:59", "巴黎夏令时前")
        expect(WorldClockText.time(at: afterParis, zone: paris) == "03:00:00", "巴黎夏令时后")
        let mondayUTC = try date("2026-11-16T00:30:00Z")
        let english = Locale(identifier: "en")
        let localDate = WorldClockText.calendarDate(at: mondayUTC, zone: ny, locale: english)
        expect(localDate.contains("Sunday") && localDate.contains("15"), "日期星期按纽约当地而非UTC")
        expect(WorldClockText.time(at: mondayUTC, zone: ny) == "19:30:00", "强制24小时完整时分秒")
        let utc = TimeZone(secondsFromGMT: 0)!
        let midnight = try date("2026-11-16T00:05:09Z")
        let noon = try date("2026-11-16T12:05:09Z")
        let evening = try date("2026-11-16T23:59:59Z")
        expect(WorldClockText.time(at: midnight, zone: utc, twelveHour: true) == "12:05:09 AM", "午夜12AM")
        expect(WorldClockText.time(at: noon, zone: utc, twelveHour: true) == "12:05:09 PM", "正午12PM")
        expect(WorldClockText.time(at: evening, zone: utc, twelveHour: true) == "11:59:59 PM", "十二小时夜间")
        expect(WorldClockText.time(at: midnight, zone: utc) == "00:05:09", "首页默认仍24小时")
        for language in ["zh-Hans", "zh-Hant", "bo", "en", "ja", "fr", "es", "de", "ru", "ko"] {
            let city = WorldClockText.city(at: summer, zone: paris, locale: Locale(identifier: language))
            expect(!city.isEmpty && city != paris.identifier, "十语ICU代表城市可用")
        }
        expect(!WorldClockCatalog.entries(at: winter, identifiers: ["invalid"]).contains(where: { $0.id == "invalid" }), "失效时区不生成坏行")
        expect(WorldClockCatalog.entries(at: winter).first?.offset == -43200, "贝克岛补齐系统known列表未列的负12小时")
        expect(WorldClockCatalog.localEntry(at: winter, timeZone: ny).offset == -18000, "当前时区独立且准确")
        expect(WorldClockCatalog.localEntry(at: summer, timeZone: ny).offsetLabel == "UTC−04:00", "偏移文案包含分钟和符号")
        let kathmandu = TimeZone(identifier: "Asia/Kathmandu")!
        expect(WorldClockCatalog.localEntry(at: summer, timeZone: kathmandu).offsetLabel == "UTC+05:45", "非整点偏移文案")

        for area in [CGSize(width: 240, height: 320), CGSize(width: 390, height: 700), CGSize(width: 844, height: 250)] {
            for size in [CGSize(width: 130, height: 65), CGSize(width: area.width - 16, height: 200)] {
                for edge in FloatingClockGeometry.Edge.allCases {
                    let point = FloatingClockGeometry.position(CGPoint(x: 9999, y: -100), size: size, area: area, edge: edge)
                    expect(point.x >= 8 && point.y >= 8 && point.x + size.width <= area.width - 8,
                           "不同可用尺寸/大字内容不超出安全宽")
                    let resized = FloatingClockGeometry.position(point, size: CGSize(width: 100, height: 60),
                                                                 area: CGSize(width: 600, height: 500), edge: edge)
                    switch edge {
                    case .left:
                        expect(resized.x == 8, "旋转后保持左吸边")
                    case .right:
                        expect(resized.x == 492, "旋转后保持右吸边")
                    case .top:
                        expect(resized.y == 8, "旋转后保持上吸边")
                    case .bottom:
                        expect(resized.y == 432, "旋转后保持下吸边")
                    }
                }
            }
        }
        let clock = JobsSwiftUIClock()
        clock.setActive(true)
        let first = clock.now
        clock.setActive(true)
        RunLoop.main.run(until: Date().addingTimeInterval(1.15))
        expect(clock.now > first && clock.isRunning, "真实主RunLoop按秒更新")
        clock.setActive(false)
        let stopped = clock.now
        RunLoop.main.run(until: Date().addingTimeInterval(1.15))
        expect(clock.now == stopped && !clock.isRunning, "离开后取消订阅且不接迟到tick")
        clock.setActive(true)
        expect(clock.now > stopped, "恢复立即读取绝对时间")
        let resumed = clock.now
        NotificationCenter.default.post(name: .NSSystemTimeZoneDidChange, object: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        expect(clock.now > resumed, "时区变动立即重算")
        clock.setActive(false)
        print("WorldClock: \(assertions) assertions passed")
    }

    private static var assertions = 0

    private static func date(_ value: String) throws -> Date {
        try Date(value, strategy: .iso8601)
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        precondition(condition(), message)
        assertions += 1
    }
}
