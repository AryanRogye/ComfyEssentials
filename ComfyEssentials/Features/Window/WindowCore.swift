//
//  WindowCore.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import Foundation
import ScreenCaptureKit
import ComfyWindowKit

@Observable
@MainActor
public final class WindowCore {
    
    /**
     * All User Windows
     */
    public var windows: [ComfyWindow] = []
    
    /**
     We cache WindowElements when the window is in the active Space
     because they behave more reliably.
     
     AXUIElements can act differently depending on when/how they’re grabbed.
     Reusing a previously cached one keeps window interactions stable.
     */
    private var elementCache: [CGWindowID: WindowElement] = [:]
    
    var bootTask : Task<Void, Never>?
    
    /**
     * This is the task that holds a run of the loadTask in a non async function
     */
    private var unAsyncLoadWindowTask: Task<Void, Never>?
    
    /**
     * Main Load Window Task
     */
    var loadWindowTask: Task<[ComfyWindow], Never>?
    
    
    @ObservationIgnored
    static let ignore_list = [
        "com.aryanrogye.ComfyTile"
    ]
    
    /**
     * Observers are used for knowing when a app got focused
     * and for when spaces got changed, this lets us call our
     * getFocusedWindow function and set that window to the
     * 0th index or the most recent cuz it is
     */
    private var observers: [NSObjectProtocol] = []
    
    public init() {
        bootTask = Task { [weak self] in
            guard let self else { return }
            /// Initial Load of all windows
            await self.loadWindows()
            /// Assign Possible Observations we wanna watch for
            assignObservers()
        }
    }
    
    @MainActor
    deinit {
        let center = NSWorkspace.shared.notificationCenter
        for observer in observers {
            center.removeObserver(observer)
        }
    }
}

// MARK: - Initial Boot
extension WindowCore {
    /**
     * Subscribes to workspace-level events (**App Activation**, **Space Change**)
     * to keep the internal window ordering in sync with system focus.
     *
     * Whenever the active app or space changes, the currently focused window
     * is moved to the front of our tracked windows list.
     */
    internal func assignObservers() {
        let center = NSWorkspace.shared.notificationCenter
        
        observers.append(
            center.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.addFocusedToFront()
                }
            }
        )
        observers.append(
            center.addObserver(
                forName: NSWorkspace.activeSpaceDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.addFocusedToFront()
                }
            }
        )
    }
}

// MARK: - Main Loading Of Windows
extension WindowCore {
    public func unAsyncLoadWindows(completion: @escaping () -> Void) {
        unAsyncLoadWindowTask?.cancel()
        unAsyncLoadWindowTask = Task {
            await loadWindows()
            completion()
        }
    }
    
    @discardableResult
    public func loadWindows() async -> [ComfyWindow] {
        var allWindows: [SCWindow]
        
        /// Use ScreenRecordingKit to get all windows the user owns
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: false)
            allWindows = content.windows
        } catch {
            print("There Was an Error Getting the Windows With SCShareableContent: \(error)")
            return []
        }
        
        /// return [] on no windows found
        if allWindows.isEmpty {
            print("No Windows Found")
            return []
        }
        
        let cscWindows: [ComfySCWindow] = ComfySCWindow.toComfySCWindows(allWindows)
        
        loadWindowTask = Task.detached(priority: .userInitiated) { [weak self, cscWindows] in
            guard let self else { return [] }
            var userWindows: [ComfyWindow] = []
            for w in cscWindows {
                /// Create a ComfyWindow Object
                if let cw = await ComfyWindow(window: w) {
                    
                    await MainActor.run {
                        if let windowID = cw.windowID {
                            /// if the element in ComfyWindow is a valid AXUIElement?, we can update cache
                            if cw.element.element != nil {
                                self.elementCache[windowID] = cw.element
                            }
                            /// if AXUIElement is nil, we can check our cache and update
                            else if let element = self.elementCache[windowID] {
                                cw.element = element
                            }
                            /// Brute-force fallback: resolve via _AXUIElementCreateWithRemoteToken
                            /// This catches windows on other Spaces, minimized, or hidden
                            /// that neither standard AX nor our cache can find
                            else if let ax = WindowServerBridge.shared.resolveAXElement(
                                pid: cw.pid,
                                windowID: windowID
                            ) {
                                let resolved = WindowElement(element: ax)
                                cw.element = resolved
                                self.elementCache[windowID] = resolved
                            }
                        }
                    }
                    /// Add Window into userWindows
                    userWindows.append(cw)
                    
                }
            }
            /// Return of the task
            return userWindows
        }
        
        
        if let loadWindowTask = loadWindowTask {
            let userWindows = await loadWindowTask.value
            if userWindows.isEmpty { return [] }
            
            // fast lookup of the newest snapshot by windowID
            let newByID = Dictionary(uniqueKeysWithValues: userWindows.map { ($0.windowID, $0) })
            
            var merged: [ComfyWindow] = []
            merged.reserveCapacity(userWindows.count)
            
            // 1) preserve previous order (self.windows), refreshing data when present
            var seen = Set<String>()
            seen.reserveCapacity(userWindows.count)
            
            for old in self.windows {
                if let updated = newByID[old.windowID] {
                    merged.append(updated)
                    seen.insert(old.id)
                }
            }
            
            // 2) append any brand-new windows (order = snapshot order for new ones)
            for w in userWindows where !seen.contains(w.id) {
                merged.append(w)
                seen.insert(w.id)
            }
            
            self.windows = merged
            return merged
        } else {
            return []
        }
    }
    
    public func quit(_ window: ComfyWindow) {
        /// find the index
        guard let index = windows.firstIndex(where: {$0.id == window.id }) else { return }
        windows.remove(at: index)
        window.element.quit()
    }
    /**
     * Public function to focus the window at the specified index
     * this then ads the window to the front of the list
     */
    public func focusWindow(at index: Int) {
        if windows.indices.contains(index) {
            windows[index].focusWindow()
            addWindowToFront(at: index)
        }
    }
}

// MARK: - Main Focus Window
extension WindowCore {
    
    internal func activeWindowElement(for pid: pid_t) -> WindowElement? {
        let appEl = AXUIElementCreateApplication(pid)
        var focused: CFTypeRef?
        let r = AXUIElementCopyAttributeValue(appEl, kAXFocusedWindowAttribute as CFString, &focused)
        guard r == .success, let focused else { return nil }
        // Ensure the returned CFType is actually an AXUIElement before casting
        guard CFGetTypeID(focused) == AXUIElementGetTypeID() else { return nil }
        let element = focused as! AXUIElement
        
        return WindowElement(element: element)
    }

    
    /// This is used for Tiling + Layouts
    ///
    /// Layouts, use focusing on the WindowElement then call Focus

    public func getFocusedWindow() -> ComfyWindow? {
        // If we can't get the screen under the mouse, stop.
        guard let screen = Self.screenUnderMouse() else {
            print("❌ Failed to determine screen under mouse")
            return nil
        }
        
        // Get the frontmost app.
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        guard let bundle = app.bundleIdentifier else { return nil }
        let pid = app.processIdentifier
        
        if Self.ignore_list.contains(bundle) { return nil }
        
        let appElement = AXUIElementCreateApplication(pid)
        
        // Ask Accessibility for the app's focused window.
        var focusedWindow: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedWindowAttribute as CFString,
            &focusedWindow
        )
        // If that fails, stop.
        if result != .success {
            print("❌ Failed to get focused window: \(result)")
            return nil
        }
        let windowElement = focusedWindow as! AXUIElement
        let element : WindowElement = WindowElement(element: windowElement)

        return ComfyWindow(
            app: app,
            windowID: element.cgWindowID,
            windowTitle: element.title ?? "Unamed",
            element: element,
            screen: screen,
            bundleIdentifier: app.bundleIdentifier,
            pid: app.processIdentifier,
            /// Most Likely Focused will always be in space
            isInSpace: true
        )
    }
}

// MARK: - Helpers
extension WindowCore {
    
    /**
     * Function Adds the Focused Window to the
     * front of the windows list by making
     * sure we have a valid windowID, we find it
     * in our windows list and we bump
     * it to the 0th or first index
     */
    internal func addFocusedToFront() {
        if let w = getFocusedWindow(),
           let wID = w.windowID,
           let index = windows.firstIndex(where: { $0.windowID == wID }) {
            addWindowToFront(at: index)
        }
    }
    
    /**
     * Function moves the window at the specified index
     * to the front of the windows list by making it the
     * 0th index
     */
    internal func addWindowToFront(at index: Int) {
        if windows.indices.contains(index) {
            /// Remove
            let focused = windows.remove(at: index)
            
            /// Add to front
            windows.insert(focused, at: 0)
        }
    }
    
    /**
     * Function Returns true if the window
     * is fullscreen or not
     */
    internal func isFullScreen(
        on window: ComfyWindow?
    ) -> Bool {
        if let element = window?.element.element {
            var value: CFTypeRef?
            AXUIElementCopyAttributeValue(element,
                                          kAXFullscreenAttribute as CFString,
                                          &value)
            if let bool = value as? Bool {
                return bool
            }
        }
        return false
    }

    /// Global Helper
    
    /**
     * Grab the screen under the mouse
     */
    public static func screenUnderMouse() -> NSScreen? {
        let loc = NSEvent.mouseLocation
        return NSScreen.screens.first {
            NSMouseInRect(loc, $0.frame, false)
        }
    }
}

#if DEBUG
extension WindowCore {
    public func debugPress() {
        print()
        print("✅ =================DEBUG START=================")

        print("✅ ==================DEBUG END==================")
        print()
    }
}
#endif

