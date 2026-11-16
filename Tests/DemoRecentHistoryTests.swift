//
//  DemoRecentHistoryTests.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import Foundation

/// 隔离测试真实历史存储模型，不创建 App 或改动用户偏好；与模型源码一起用 swiftc 编译后运行。
@main
enum DemoRecentHistoryTests {

    static func main() {
        let suite = "com.jobs.swiftui.recent.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer {
            defaults.removePersistentDomain(forName: suite)
        }
        let known = (0..<45).map { "feature-\($0)" }
        let key = "history"
        defaults.set(["removed", known[2], known[2], known[1]], forKey: key)
        let history = DemoRecentHistory(availableIDs: known, defaults: defaults, key: key)
        expect(history.featureIDs == [known[2], known[1]], "恢复时过滤未知和重复ID")
        expect(defaults.stringArray(forKey: key) == history.featureIDs, "净化后回写存储")

        history.record(known[1])
        expect(history.featureIDs == [known[1], known[2]], "重新打开已有项去重并前插")
        let restored = DemoRecentHistory(availableIDs: known, defaults: defaults, key: key)
        expect(restored.featureIDs == history.featureIDs, "新实例恢复持久顺序")
        history.record(known[3])
        restored.record(known[4])
        expect(restored.featureIDs.prefix(2) == [known[4], known[3]], "不同Scene实例合并最新落盘顺序")

        known.forEach(history.record)
        expect(history.featureIDs.count == 30, "容量最多30")
        expect(history.featureIDs == Array(known.reversed().prefix(30)), "超容量淘汰最久项")
        history.record(known[20])
        expect(history.featureIDs.first == known[20] && history.featureIDs.count == 30, "容量满时访问旧项不重复")
        expect(Set(history.featureIDs).count == 30, "持久列表中的ID唯一")
        let before = history.featureIDs
        history.record("removed")
        expect(history.featureIDs == before, "未知ID不会产生访问记录")

        let current = DemoRecentHistory(availableIDs: [known[20], known[44]], defaults: defaults, key: key)
        expect(current.featureIDs == [known[20], known[44]], "删除或隐藏注册项后不生成失效路由")
        expect(defaults.stringArray(forKey: key) == current.featureIDs, "失效项清理持久化")
        defaults.set(123, forKey: key)
        current.reload()
        expect(current.featureIDs.isEmpty, "损坏的偏好类型恢复为空列表")
        print("DemoRecentHistory: 13 assertions passed")
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        precondition(condition(), message)
    }
}
