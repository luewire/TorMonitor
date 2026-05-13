import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService: ObservableObject {
    static let shared = LaunchAtLoginService()

    @Published var isEnabled: Bool = false

    private init() {
        refresh()
    }

    func refresh() {
        if #available(macOS 13.0, *) {
            isEnabled = SMAppService.mainApp.status == .enabled
        }
    }

    func toggle() {
        if isEnabled {
            disable()
        } else {
            enable()
        }
    }

    func enable() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                isEnabled = true
            } catch {
#if DEBUG
                NSLog("LaunchAtLogin register failed: \(error)")
#endif
                isEnabled = false
            }
        }
    }

    func disable() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.unregister()
                isEnabled = false
            } catch {
#if DEBUG
                NSLog("LaunchAtLogin unregister failed: \(error)")
#endif
                refresh()
            }
        }
    }
}
