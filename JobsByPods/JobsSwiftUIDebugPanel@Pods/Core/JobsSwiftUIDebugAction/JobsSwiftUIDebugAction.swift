//
//  JobsSwiftUIDebugAction.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI

public final class JobsSwiftUIDebugAction: Identifiable {
    public let id = UUID()
    public private(set) var title = ""
    public private(set) var image: Image?
    internal var handler: (@MainActor () -> Void)?
    internal var destination: (@MainActor () -> AnyView)?

    public init() {}

    @discardableResult
    public func byTitle(_ value: String) -> Self {
        title = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return self
    }

    @discardableResult
    public func byImage(_ value: Image?) -> Self {
        image = value
        return self
    }

    @discardableResult
    public func byAction(_ action: @escaping @MainActor () -> Void) -> Self {
        handler = action
        destination = nil
        return self
    }

    @discardableResult
    public func byDestination<Destination: View>(@ViewBuilder _ builder: @escaping @MainActor () -> Destination) -> Self {
        destination = {
            AnyView(builder())
        }
        handler = nil
        return self
    }
}
#endif
