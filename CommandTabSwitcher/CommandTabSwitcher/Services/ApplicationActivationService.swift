import AppKit
import ApplicationServices

final class ApplicationActivationService {
    func activate(_ item: SwitcherItem) {
        let application = item.runningApplication

        guard !application.isTerminated else {
            Logger.warning(
                "\(item.applicationName) terminated before activation."
            )
            return
        }

        application.unhide()

        let activated = application.activate(
            options: [
                .activateAllWindows,
                .activateIgnoringOtherApps
            ]
        )

        if activated {
            raiseWindow(item.windowID)

            Logger.info(
                "Activated \(item.applicationName)."
            )
        } else {
            Logger.warning(
                "Could not activate \(item.applicationName)."
            )
        }
    }

    private func raiseWindow(
        _ windowID: CGWindowID
    ) {
        let systemWideElement = AXUIElementCreateSystemWide()

        var focusedApplicationValue: CFTypeRef?

        let applicationResult = AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedApplicationAttribute as CFString,
            &focusedApplicationValue
        )

        guard applicationResult == .success,
              let focusedApplicationValue else {
            return
        }

        let applicationElement = unsafeBitCast(
            focusedApplicationValue,
            to: AXUIElement.self
        )

        var windowsValue: CFTypeRef?

        let windowsResult = AXUIElementCopyAttributeValue(
            applicationElement,
            kAXWindowsAttribute as CFString,
            &windowsValue
        )

        guard windowsResult == .success,
              let windows = windowsValue as? [AXUIElement] else {
            return
        }

        for window in windows {
            AXUIElementPerformAction(
                window,
                kAXRaiseAction as CFString
            )
        }
    }
}