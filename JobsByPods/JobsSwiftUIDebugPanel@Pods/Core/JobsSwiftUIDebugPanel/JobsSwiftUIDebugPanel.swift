//
//  JobsSwiftUIDebugPanel.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI
import UIKit
import Combine

@MainActor
public final class JobsSwiftUIDebugPanel: ObservableObject {
    public static let shared = JobsSwiftUIDebugPanel()
    public static let environmentDidChange = Notification.Name("JobsSwiftUIDebugEnvironmentDidChange")
    @Published public private(set) var environments: [JobsSwiftUIDebugEnvironment] = []
    @Published public private(set) var actions: [JobsSwiftUIDebugAction] = []
    @Published public private(set) var currentEnvironment: JobsSwiftUIDebugEnvironment?
    @Published internal var feedback: String?
    private let persistenceKey = "com.jobs.swiftui.debugPanel.environment"
    private var defaultIdentifier = ""
    private var environmentChanged: ((JobsSwiftUIDebugEnvironment) -> Void)?
    private var started = false
    private var hiddenForCurrentLaunch = false
    private var refreshing = false
    private var observers: [NSObjectProtocol] = []
    private var bindings: [String: WeakSceneState] = [:]
    private var windows: [String: JobsSwiftUIDebugOverlayWindow] = [:]

    private init() {}

    public nonisolated static var buttonImage: Image {
        JobsSwiftUIDebugResource.buttonImage
    }

    @discardableResult
    public func byEnvironments(_ values: [JobsSwiftUIDebugEnvironment]) -> Self {
        var identifiers = Set<String>()
        environments = values.compactMap { value in
            guard let url = URL(string: value.baseURL),
                  let scheme = url.scheme?.lowercased(),
                  ["http", "https"].contains(scheme),
                  let host = url.host, !host.isEmpty,
                  identifiers.insert(value.id).inserted else {
                return nil
            }
            return JobsSwiftUIDebugEnvironment()
                .byIdentifier(value.id)
                .byTitle(value.title.isEmpty ? value.id : value.title)
                .byBaseURL(value.baseURL)
        }
        if started {
            restoreEnvironment()
        }
        return self
    }

    @discardableResult
    public func byDefaultEnvironmentIdentifier(_ value: String) -> Self {
        defaultIdentifier = value
        return self
    }

    @discardableResult
    public func byEnvironmentChanged(_ action: @escaping (JobsSwiftUIDebugEnvironment) -> Void) -> Self {
        environmentChanged = action
        return self
    }

    @discardableResult
    public func byActions(_ values: [JobsSwiftUIDebugAction]) -> Self {
        actions = values.compactMap { value in
            guard !value.title.isEmpty, value.handler != nil || value.destination != nil else {
                return nil
            }
            let snapshot = JobsSwiftUIDebugAction()
                .byTitle(value.title)
                .byImage(value.image)
            snapshot.handler = value.handler
            snapshot.destination = value.destination
            return snapshot
        }
        return self
    }

    @discardableResult
    public func byStart() -> Self {
        restoreEnvironment()
        guard !started else {
            refreshWindows()
            return self
        }
        started = true
        let names: [Notification.Name] = [
            UIScene.didActivateNotification, UIScene.willDeactivateNotification,
            UIScene.didDisconnectNotification, UIWindow.didBecomeKeyNotification,
            UIWindow.didBecomeVisibleNotification, UIApplication.didBecomeActiveNotification
        ]
        observers = names.map { name in
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in
                    self?.refreshWindows()
                }
            }
        }
        refreshWindows()
        return self
    }

    @discardableResult
    public func byHideForCurrentLaunch() -> Self {
        hiddenForCurrentLaunch = true
        for window in windows.values {
            window.isHidden = true
        }
        return self
    }

    @discardableResult
    public func byFeedback(_ value: String) -> Self {
        feedback = value
        return self
    }

    public func select(_ environment: JobsSwiftUIDebugEnvironment) {
        guard let configured = environments.first(where: {
            $0.id == environment.id
        }) else {
            return
        }
        currentEnvironment = configured
        UserDefaults.standard.set(configured.id, forKey: persistenceKey)
        environmentChanged?(configured)
        NotificationCenter.default.post(name: Self.environmentDidChange, object: configured)
    }

    internal func attach(_ state: JobsSwiftUIDebugSceneState, to window: UIWindow) {
        guard !(window is JobsSwiftUIDebugOverlayWindow), let scene = window.windowScene else {
            return
        }
        state.hostWindow = window
        bindings[scene.session.persistentIdentifier] = WeakSceneState(value: state)
        refreshWindows()
    }

    internal func open(_ state: JobsSwiftUIDebugSceneState) {
        guard started, !hiddenForCurrentLaunch else {
            return
        }
        state.isPresented = true
    }

    internal func toggle(_ state: JobsSwiftUIDebugSceneState) {
        guard started, !hiddenForCurrentLaunch else {
            return
        }
        state.isPresented.toggle()
        if !state.isPresented {
            feedback = nil
        }
    }

    internal func synchronizeAppearance(_ scheme: ColorScheme, for state: JobsSwiftUIDebugSceneState) {
        if state.colorScheme != scheme {
            state.colorScheme = scheme
        }
        for window in windows.values where window.sceneState === state {
            window.overrideUserInterfaceStyle = scheme == .dark ? .dark : .light
        }
    }

    private func restoreEnvironment() {
        let saved = UserDefaults.standard.string(forKey: persistenceKey)
        let selected = environments.first(where: {
            $0.id == saved
        }) ?? environments.first(where: {
            $0.id == defaultIdentifier
        })
            ?? environments.first
        if let selected {
            select(selected)
        } else {
            currentEnvironment = nil
        }
    }

    private func refreshWindows() {
        guard started, !hiddenForCurrentLaunch, !refreshing else {
            return
        }
        refreshing = true
        defer {
            refreshing = false
        }
        let scenes = UIApplication.shared.connectedScenes.compactMap {
            $0 as? UIWindowScene
        }
        let liveIdentifiers = Set(scenes.map {
            $0.session.persistentIdentifier
        })
        for identifier in Array(windows.keys) where !liveIdentifiers.contains(identifier) {
            windows.removeValue(forKey: identifier)?.isHidden = true
            bindings.removeValue(forKey: identifier)
        }
        for scene in scenes {
            let identifier = scene.session.persistentIdentifier
            guard scene.activationState == .foregroundActive,
                  let state = bindings[identifier]?.value else {
                windows[identifier]?.isHidden = true
                continue
            }
            let candidates = scene.windows.filter {
                !($0 is JobsSwiftUIDebugOverlayWindow) && !$0.isHidden && $0.windowLevel == .normal && $0.rootViewController != nil
            }
            guard let host = candidates.first(where: {
                $0.isKeyWindow
            }) ?? candidates.first else {
                windows[identifier]?.isHidden = true
                continue
            }
            state.hostWindow = host
            if let existing = windows[identifier],
               existing.hostWindow === host,
               existing.sceneState === state {
                existing.frame = scene.coordinateSpace.bounds
                existing.overrideUserInterfaceStyle = state.colorScheme == .dark ? .dark : .light
                existing.isHidden = false
                continue
            }
            windows.removeValue(forKey: identifier)?.isHidden = true
            let window = JobsSwiftUIDebugOverlayWindow(windowScene: scene)
            window.frame = scene.coordinateSpace.bounds
            window.hostWindow = host
            window.sceneState = state
            window.overrideUserInterfaceStyle = state.colorScheme == .dark ? .dark : .light
            let root = JobsSwiftUIDebugOverlayView(state: state) { [weak window] frame in
                window?.buttonFrame = frame
            }
            let controller = UIHostingController(rootView: root)
            controller.view.backgroundColor = .clear
            window.rootViewController = controller
            window.backgroundColor = .clear
            window.windowLevel = .alert + 100
            windows[identifier] = window
            window.isHidden = false
        }
    }

    private struct WeakSceneState {
        weak var value: JobsSwiftUIDebugSceneState?
    }
}
#endif
