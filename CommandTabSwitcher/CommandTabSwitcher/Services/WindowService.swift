import AppKit
import CoreGraphics

final class WindowService {
    private let screenCaptureService: ScreenCaptureService

    init(
        screenCaptureService: ScreenCaptureService
    ) {
        self.screenCaptureService = screenCaptureService
    }

    func fetchVisibleWindows() -> [WindowItem] {
        let options: CGWindowListOption = [
            .optionOnScreenOnly,
            .excludeDesktopElements
        ]

        guard let windowInfoList = CGWindowListCopyWindowInfo(
            options,
            kCGNullWindowID
        ) as? [[String: Any]] else {
            Logger.error("Could not read the current window list.")
            return []
        }

        let ownProcessIdentifier =
            ProcessInfo.processInfo.processIdentifier

        var results: [WindowItem] = []
        var includedProcesses = Set<pid_t>()

        for windowInfo in windowInfoList {
            guard let windowItem = createWindowItem(
                from: windowInfo,
                ownProcessIdentifier: ownProcessIdentifier
            ) else {
                continue
            }

            /*
             For now, only include one visible window per application.
             The first suitable window is usually the frontmost window.
             */
            guard !includedProcesses.contains(
                windowItem.processIdentifier
            ) else {
                continue
            }

            includedProcesses.insert(
                windowItem.processIdentifier
            )

            results.append(windowItem)
        }

        Logger.info(
            "Loaded \(results.count) visible application windows."
        )

        return results
    }

    private func createWindowItem(
        from windowInfo: [String: Any],
        ownProcessIdentifier: pid_t
    ) -> WindowItem? {
        guard let windowNumber = windowInfo[
            kCGWindowNumber as String
        ] as? NSNumber else {
            return nil
        }

        guard let ownerPIDNumber = windowInfo[
            kCGWindowOwnerPID as String
        ] as? NSNumber else {
            return nil
        }

        guard let ownerName = windowInfo[
            kCGWindowOwnerName as String
        ] as? String else {
            return nil
        }

        let processIdentifier = pid_t(
            ownerPIDNumber.int32Value
        )

        guard processIdentifier != ownProcessIdentifier else {
            return nil
        }

        guard let layerNumber = windowInfo[
            kCGWindowLayer as String
        ] as? NSNumber,
              layerNumber.intValue == 0 else {
            return nil
        }

        guard let alphaNumber = windowInfo[
            kCGWindowAlpha as String
        ] as? NSNumber,
              alphaNumber.doubleValue > 0 else {
            return nil
        }

        guard let boundsDictionary = windowInfo[
            kCGWindowBounds as String
        ] as? [String: Any] else {
            return nil
        }

        let boundsCFDictionary =
            boundsDictionary as CFDictionary

        guard let bounds = CGRect(
            dictionaryRepresentation: boundsCFDictionary
        ) else {
            return nil
        }

        /*
         Ignore menu extras, tooltips, status items,
         tiny helper windows and invisible windows.
         */
        guard bounds.width >= 160,
              bounds.height >= 100 else {
            return nil
        }

        guard let runningApplication = NSRunningApplication(
            processIdentifier: processIdentifier
        ) else {
            return nil
        }

        guard runningApplication.activationPolicy == .regular else {
            return nil
        }

        guard !runningApplication.isTerminated else {
            return nil
        }

        let windowID = CGWindowID(
            windowNumber.uint32Value
        )

        let windowTitle = windowInfo[
            kCGWindowName as String
        ] as? String ?? ""

        let applicationIcon =
            runningApplication.icon
            ?? NSImage(
                systemSymbolName: "app.fill",
                accessibilityDescription: ownerName
            )
            ?? NSImage()

        let previewImage = screenCaptureService.captureWindow(
            windowID: windowID
        )

        return WindowItem(
            windowID: windowID,
            processIdentifier: processIdentifier,
            applicationName: ownerName,
            windowTitle: windowTitle,
            bundleIdentifier: runningApplication.bundleIdentifier,
            bounds: bounds,
            applicationIcon: applicationIcon,
            previewImage: previewImage,
            runningApplication: runningApplication
        )
    }
}