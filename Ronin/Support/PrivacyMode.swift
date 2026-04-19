import SwiftUI

enum PrivacyMode {
    static let appStorageKey = "privacyModeEnabled"
    static let maskedValue = "••••"

    static func display(_ value: String, isEnabled: Bool) -> String {
        isEnabled ? maskedValue : value
    }
}

struct PrivacyToolbarButton: View {
    @AppStorage(PrivacyMode.appStorageKey) private var isPrivacyEnabled = false

    var body: some View {
        Button {
            isPrivacyEnabled.toggle()
        } label: {
            Image(systemName: isPrivacyEnabled ? "eye.slash.fill" : "eye.fill")
        }
        .accessibilityLabel(isPrivacyEnabled ? "Mostrar valores" : "Ocultar valores")
    }
}
