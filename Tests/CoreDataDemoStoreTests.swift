//
//  CoreDataDemoStoreTests.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import Foundation

/// 编译真实模型并传入临时目录，验证真实 SQLite，不触碰 App 数据。
@main
enum CoreDataDemoStoreTests {

    @MainActor
    static func main() throws {
        let modelURL = URL(fileURLWithPath: CommandLine.arguments[1])
        if CommandLine.arguments.count == 4 {
            let store = CoreDataDemoStore(modelURL: modelURL,
                                          storeURL: URL(fileURLWithPath: CommandLine.arguments[2]))
            store.reload()
            if CommandLine.arguments[3] == "--seed" {
                expect(store.add(title: "CoreData process persistence"), "隔离模拟器数据库写入")
            } else {
                expect(store.isReady && store.records.count == 2, "独立进程恢复两条记录")
                expect(store.records.contains(where: { $0.title == "Renamed" && $0.isComplete }), "独立进程恢复修改字段")
            }
            return
        }
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("jobs-coredata-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        let database = directory.appendingPathComponent("nested/records.sqlite")
        let store = CoreDataDemoStore(modelURL: modelURL, storeURL: database)
        store.reload()
        expect(store.isReady && store.records.isEmpty && store.failureKey == nil, "真实模型加载，默认空")
        expect(!store.add(title: "  \n"), "拒绝空白标题")
        expect(store.records.isEmpty && store.failureKey == "标题不能为空。", "失败不会生成假记录")
        expect(store.add(title: "  First  "), "新增并保存")
        let first = store.records[0]
        expect(first.title == "First" && !first.isComplete, "裁剪标题，默认未完成")
        expect(store.add(title: "Second"), "新增第二条")
        expect(store.records.count == 2 && store.records.first?.title == "Second", "按创建时间倒序查询")
        expect(store.rename(id: first.id, title: "Renamed"), "修改并保存标题")
        store.toggle(id: first.id)
        expect(store.records.first(where: { $0.id == first.id })?.isComplete == true, "切换完成状态")

        let restored = CoreDataDemoStore(modelURL: modelURL, storeURL: database)
        restored.reload()
        expect(restored.records == store.records, "独立容器从SQLite恢复全部字段")
        expect(FileManager.default.fileExists(atPath: database.path), "确实生成SQLite文件")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        process.arguments = [modelURL.path, database.path, "--restore"]
        try process.run()
        process.waitUntilExit()
        expect(process.terminationStatus == 0, "独立进程从SQLite恢复成功")
        expect(!restored.rename(id: first.id, title: "\n"), "无效改名失败")
        expect(restored.records.first(where: { $0.id == first.id })?.title == "Renamed", "改名失败保留原数据")
        restored.delete(id: first.id)
        expect(restored.records.count == 1 && restored.records[0].title == "Second", "删除指定记录")
        restored.deleteAll()
        restored.reload()
        expect(restored.records.isEmpty, "清空后重载仍为空")

        let missing = CoreDataDemoStore(modelURL: nil, storeURL: directory.appendingPathComponent("missing.sqlite"))
        missing.reload()
        expect(!missing.isReady && missing.failureKey == "不能读取数据库模型。", "缺少模型可恢复报错，不崩溃")
        expect(!missing.add(title: "Blocked") && missing.records.isEmpty, "未就绪禁止写入")

        let blocked = directory.appendingPathComponent("blocked")
        try Data("file".utf8).write(to: blocked)
        let retry = CoreDataDemoStore(modelURL: modelURL, storeURL: blocked.appendingPathComponent("retry.sqlite"))
        retry.reload()
        expect(!retry.isReady && retry.failureKey != nil, "目录不可用时返回加载错误")
        try FileManager.default.removeItem(at: blocked)
        retry.reload()
        expect(retry.isReady && retry.failureKey == nil, "修复目录后重试真实加载成功")
        expect(retry.add(title: "Recovered"), "恢复后真实写入")
        print("CoreDataDemoStore: 21 assertions passed (SQLite + independent process)")
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        precondition(condition(), message)
    }
}
