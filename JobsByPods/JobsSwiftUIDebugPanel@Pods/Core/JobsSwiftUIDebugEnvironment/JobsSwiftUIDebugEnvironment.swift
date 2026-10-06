//
//  JobsSwiftUIDebugEnvironment.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import Foundation

public final class JobsSwiftUIDebugEnvironment: Identifiable {
    public private(set) var identifier = ""
    public private(set) var title = ""
    public private(set) var baseURL = ""
    public var id: String {
        identifier.isEmpty ? baseURL : identifier
    }

    public init() {}

    @discardableResult
    public func byIdentifier(_ value: String) -> Self {
        identifier = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return self
    }

    @discardableResult
    public func byTitle(_ value: String) -> Self {
        title = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return self
    }

    @discardableResult
    public func byBaseURL(_ value: String) -> Self {
        baseURL = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return self
    }
}
#endif
