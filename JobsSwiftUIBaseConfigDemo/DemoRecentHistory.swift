//
//  DemoRecentHistory.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import Foundation
import Combine

/// 历史仅保存注册表稳定 ID，避免标题翻译或目录顺序改变后指向其它功能。
final class DemoRecentHistory: ObservableObject {

    static let storageKey = "JobsSwiftUIBaseConfigDemo.recentDemoIDs"
    static let capacity = 30

    @Published private(set) var featureIDs: [String] = []

    private let defaults: UserDefaults
    private let key: String
    private let availableIDs: Set<String>

    init(availableIDs: [String], defaults: UserDefaults = .standard, key: String = DemoRecentHistory.storageKey) {
        self.availableIDs = Set(availableIDs)
        self.defaults = defaults
        self.key = key
        reload()
    }

    func reload() {
        update(defaults.stringArray(forKey: key) ?? [])
    }

    func record(_ featureID: String) {
        guard availableIDs.contains(featureID) else {
            return
        }
        /// 读最新落盘值，多个 Scene 先后访问时不以旧内存覆盖新记录。
        let saved = defaults.stringArray(forKey: key) ?? []
        update([featureID] + saved.filter { $0 != featureID })
    }

    private func update(_ candidates: [String]) {
        var seen = Set<String>()
        let valid = candidates.filter { availableIDs.contains($0) && seen.insert($0).inserted }
        let next = Array(valid.prefix(Self.capacity))
        if featureIDs != next {
            featureIDs = next
        }
        defaults.set(next, forKey: key)
    }
}
