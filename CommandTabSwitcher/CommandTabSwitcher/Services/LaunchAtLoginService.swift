import Foundation
import ServiceManagement

final class LaunchAtLoginService {
    var status: SMAppService.Status {
        SMAppService.mainApp.status
    }

    var isEnabled: Bool {
        status == .enabled
    }

    var requiresApproval: Bool {
        status == .requiresApproval
    }

    @discardableResult
    func enable() -> Bool {
        switch status {
        case .enabled:
            Logger.info("Launch at login is already enabled.")
            return true

        case .notRegistered:
            do {
                try SMAppService.mainApp.register()

                Logger.info(
                    "Launch at login was registered successfully."
                )

                return SMAppService.mainApp.status == .enabled
            } catch {
                Logger.error(
                    "Could not enable launch at login: \(error.localizedDescription)"
                )

                return false
            }

        case .requiresApproval:
            Logger.warning(
                "Launch at login requires approval in System Settings."
            )

            return false

        case .notFound:
            Logger.error(
                "The application could not be registered as a login item."
            )

            return false

        @unknown default:
            Logger.error(
                "An unknown launch at login status was returned."
            )

            return false
        }
    }

    @discardableResult
    func disable() -> Bool {
        switch status {
        case .notRegistered:
            Logger.info("Launch at login is already disabled.")
            return true

        case .notFound:
            Logger.warning(
                "The application was not found in login items."
            )

            return true

        case .enabled,
             .requiresApproval:

            do {
                try SMAppService.mainApp.unregister()

                Logger.info(
                    "Launch at login was disabled successfully."
                )

                return SMAppService.mainApp.status == .notRegistered
            } catch {
                Logger.error(
                    "Could not disable launch at login: \(error.localizedDescription)"
                )

                return false
            }

        @unknown default:
            Logger.error(
                "An unknown launch at login status was returned."
            )

            return false
        }
    }

    @discardableResult
    func toggle() -> Bool {
        if isEnabled || requiresApproval {
            return disable()
        }

        return enable()
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}