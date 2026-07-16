import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var applicationController: ApplicationController?

    func applicationDidFinishLaunching(
        _ notification: Notification
    ) {
        Logger.info("CommandTabSwitcher is starting.")

        let controller = ApplicationController()
        applicationController = controller

        controller.start()
    }

    func applicationWillTerminate(
        _ notification: Notification
    ) {
        applicationController?.stop()

        Logger.info("CommandTabSwitcher is shutting down.")
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        false
    }
}