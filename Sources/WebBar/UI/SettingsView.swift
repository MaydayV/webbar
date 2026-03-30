import SwiftUI

struct SettingsView: View {
    @Binding var launchAtLoginEnabled: Bool
    let onLaunchToggle: (Bool) -> Void

    var body: some View {
        Toggle("开机启动 WebBar", isOn: Binding(
            get: { launchAtLoginEnabled },
            set: { value in
                launchAtLoginEnabled = value
                onLaunchToggle(value)
            }
        ))
        .toggleStyle(.switch)
    }
}
