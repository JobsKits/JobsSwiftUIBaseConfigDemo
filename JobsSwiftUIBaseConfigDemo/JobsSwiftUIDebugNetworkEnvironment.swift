//
//  JobsSwiftUIDebugNetworkEnvironment.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import Foundation
import Combine

@MainActor
final class JobsSwiftUIDebugNetworkEnvironment: ObservableObject {
    static let shared = JobsSwiftUIDebugNetworkEnvironment()
    @Published private(set) var baseURL = "http://127.0.0.1:18080"

    private init() {}

    @discardableResult
    func byBaseURL(_ value: String) -> Self {
        baseURL = value
        return self
    }
}
#endif
