//
//  CoreDataDemoStore.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import Combine
import CoreData
import Foundation

/// Core Data 底层适配器；所有构造、上下文访问与立即保存都在主队列串行完成。
@MainActor
final class CoreDataDemoStore: ObservableObject {

    static let shared = CoreDataDemoStore()

    @Published private(set) var records: [CoreDataDemoRecord] = []
    @Published private(set) var isReady = false
    @Published private(set) var failureKey: String?
    @Published private(set) var diagnostic: String?

    private let modelURL: URL?
    private let storeURL: URL
    private var container: NSPersistentContainer?

    init(
        modelURL: URL? = Bundle.main.url(forResource: "JobsSwiftUIBaseConfigDemo", withExtension: "momd"),
        storeURL: URL? = nil
    ) {
        self.modelURL = modelURL
        self.storeURL = storeURL ?? NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("CoreDataDemo", isDirectory: true)
            .appendingPathComponent("JobsSwiftUIBaseConfigDemo.sqlite")
    }

    func reload() {
        perform {
            try prepareIfNeeded()
        }
    }

    @discardableResult
    func add(title: String) -> Bool {
        return perform {
            let title = try validatedTitle(title)
            let context = try readyContext()
            let object = NSEntityDescription.insertNewObject(forEntityName: "DemoNote", into: context)
            object.setValue(UUID(), forKey: "id")
            object.setValue(title, forKey: "title")
            object.setValue(Date(), forKey: "createdAt")
            object.setValue(false, forKey: "isComplete")
        }
    }

    @discardableResult
    func rename(id: UUID, title: String) -> Bool {
        return perform {
            let title = try validatedTitle(title)
            try object(id: id).setValue(title, forKey: "title")
        }
    }

    func toggle(id: UUID) {
        perform {
            let object = try object(id: id)
            let completed = object.value(forKey: "isComplete") as? Bool ?? false
            object.setValue(!completed, forKey: "isComplete")
        }
    }

    func delete(id: UUID) {
        perform {
            let object = try object(id: id)
            try readyContext().delete(object)
        }
    }

    func deleteAll() {
        perform {
            let context = try readyContext()
            let request = NSFetchRequest<NSManagedObject>(entityName: "DemoNote")
            try context.fetch(request).forEach(context.delete)
        }
    }

    private func prepareIfNeeded() throws {
        guard !isReady else {
            return
        }
        guard let modelURL, let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw StoreFailure(key: "不能读取数据库模型。")
        }
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        let candidate = NSPersistentContainer(name: "JobsSwiftUIBaseConfigDemo", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        candidate.persistentStoreDescriptions = [description]
        var loadError: Error?
        candidate.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            throw loadError
        }
        candidate.viewContext.undoManager = nil
        container = candidate
        isReady = true
    }

    private func readyContext() throws -> NSManagedObjectContext {
        guard isReady, let context = container?.viewContext else {
            throw StoreFailure(key: "数据库尚未就绪。")
        }
        return context
    }

    private func object(id: UUID) throws -> NSManagedObject {
        let request = NSFetchRequest<NSManagedObject>(entityName: "DemoNote")
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        guard let object = try readyContext().fetch(request).first else {
            throw CocoaError(.managedObjectReferentialIntegrity)
        }
        return object
    }

    private func validatedTitle(_ title: String) throws -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw StoreFailure(key: "标题不能为空。")
        }
        return trimmed
    }

    private func fetchRecords() throws -> [CoreDataDemoRecord] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "DemoNote")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try readyContext().fetch(request).map { object in
            guard let id = object.value(forKey: "id") as? UUID,
                  let title = object.value(forKey: "title") as? String,
                  let createdAt = object.value(forKey: "createdAt") as? Date,
                  let isComplete = object.value(forKey: "isComplete") as? Bool else {
                throw StoreFailure(key: "数据库记录缺少必要字段。")
            }
            return CoreDataDemoRecord(id: id, title: title, createdAt: createdAt, isComplete: isComplete)
        }
    }

    @discardableResult
    private func perform(_ action: () throws -> Void) -> Bool {
        do {
            try action()
            let context = try readyContext()
            if context.hasChanges {
                try context.save()
            }
            records = try fetchRecords()
            failureKey = nil
            diagnostic = nil
            return true
        } catch {
            container?.viewContext.rollback()
            failureKey = (error as? StoreFailure)?.key ?? "数据库操作失败"
            diagnostic = error is StoreFailure ? nil : error.localizedDescription
            return false
        }
    }

    private struct StoreFailure: Error {
        let key: String
    }
}
