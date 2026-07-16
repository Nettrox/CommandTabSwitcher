import Foundation

final class KeyboardMonitorService {
    typealias EventHandler = (KeyboardEvent) -> Void

    private let accessibilityService: AccessibilityService
    private let eventHandler: EventHandler

    private var commandTabEventTap: CommandTabEventTap?

    init(
        accessibilityService: AccessibilityService,
        eventHandler: @escaping EventHandler
    ) {
        self.accessibilityService = accessibilityService
        self.eventHandler = eventHandler
    }

    var isRunning: Bool {
        commandTabEventTap?.isRunning ?? false
    }

    @discardableResult
    func start() -> Bool {
        guard accessibilityService.isTrusted else {
            Logger.error(
                "Keyboard monitoring could not start because Accessibility permission is missing."
            )
            return false
        }

        guard commandTabEventTap == nil else {
            return true
        }

        let eventTap = CommandTabEventTap(
            eventHandler: eventHandler
        )

        guard eventTap.start() else {
            Logger.error("Keyboard monitoring could not be started.")
            return false
        }

        commandTabEventTap = eventTap

        Logger.info("Keyboard monitoring started.")

        return true
    }

    func stop() {
        commandTabEventTap?.stop()
        commandTabEventTap = nil

        Logger.info("Keyboard monitoring stopped.")
    }
}