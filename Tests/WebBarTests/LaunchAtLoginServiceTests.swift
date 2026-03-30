import XCTest
@testable import WebBar

final class LaunchAtLoginServiceTests: XCTestCase {
    func testSetEnabled() {
        let defaults = UserDefaults(suiteName: "WebBarLaunchTests.\(UUID().uuidString)")!
        let service = LaunchAtLoginService(defaults: defaults, key: "launchAtLoginEnabled.test")

        XCTAssertFalse(service.isEnabled)
        service.setEnabled(true)
        XCTAssertTrue(service.isEnabled)
        service.setEnabled(false)
        XCTAssertFalse(service.isEnabled)
    }
}
