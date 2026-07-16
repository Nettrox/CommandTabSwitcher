import AppKit
import ApplicationServices

final class PermissionService {
    var isAccessibilityPermissionGranted: Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    func requestAccessibilityPermission() -> Bool {
        let options = [
            kAXTrustedCheckOptionPrompt
                .takeUnretainedValue() as String: true
        ] as CFDictionary

        return AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilitySettings() {
        guard let url = URL(
            string: """
            x-apple.systempreferences:\
            com.apple.preference.security?Privacy_Accessibility
            """
        ) else {
            Logger.error(
                "Could not create the Accessibility settings URL."
            )
            return
        }

        NSWorkspace.shared.open(url)
    }
}