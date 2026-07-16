import AppKit

final class ApplicationService {
    private let windowService: WindowService

    init(
        windowService: WindowService
    ) {
        self.windowService = windowService
    }

    func fetchSwitcherItems() -> [SwitcherItem] {
        windowService.fetchVisibleWindows().map { window in
            SwitcherItem(
                windowID: window.windowID,
                processIdentifier: window.processIdentifier,
                applicationName: window.applicationName,
                windowTitle: window.windowTitle,
                bundleIdentifier: window.bundleIdentifier,
                applicationIcon: window.applicationIcon,
                previewImage: window.previewImage,
                runningApplication: window.runningApplication
            )
        }
    }
}