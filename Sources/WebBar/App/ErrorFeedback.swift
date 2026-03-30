import AppKit
import Foundation
import UserNotifications

@MainActor
final class ErrorFeedback {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func presentOpenFailure(for urlString: String, button: NSStatusBarButton?) {
        flashButton(button)
        notify(urlString: urlString)
    }

    private func flashButton(_ button: NSStatusBarButton?) {
        guard let button else { return }
        let originalTint = button.contentTintColor
        button.contentTintColor = .systemRed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            button.contentTintColor = originalTint
        }
    }

    private func notify(urlString: String) {
        let content = UNMutableNotificationContent()
        content.title = "WebBar 打开失败"
        content.body = "无法打开：\(urlString)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
