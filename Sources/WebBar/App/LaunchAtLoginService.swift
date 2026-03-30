import Foundation
import ServiceManagement

protocol LaunchAtLoginServing {
    var isEnabled: Bool { get }
    func setEnabled(_ enabled: Bool)
}

final class LaunchAtLoginService: LaunchAtLoginServing {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = BuildInfo.launchAtLoginKey) {
        self.defaults = defaults
        self.key = key
    }

    var isEnabled: Bool {
        defaults.bool(forKey: key)
    }

    func setEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: key)
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Failing to register helper should not break core behavior.
        }
    }
}
