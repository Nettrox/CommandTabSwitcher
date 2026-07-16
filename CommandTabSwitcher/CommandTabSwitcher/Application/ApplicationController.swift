import AppKit

final class ApplicationController: NSObject, NSMenuDelegate {
    private let permissionService: PermissionService
    private let accessibilityService: AccessibilityService
    private let screenCaptureService: ScreenCaptureService
    private let launchAtLoginService: LaunchAtLoginService

    private let windowService: WindowService
    private let applicationService: ApplicationService
    private let activationService: ApplicationActivationService
    private let switcherPanelController: SwitcherPanelController

    private var keyboardMonitorService: KeyboardMonitorService?
    private var statusItem: NSStatusItem?

    private var launchAtLoginMenuItem: NSMenuItem?

    private var switcherItems: [SwitcherItem] = []
    private var selectedIndex = 0

    override init() {
        let screenCaptureService = ScreenCaptureService()

        let windowService = WindowService(
            screenCaptureService: screenCaptureService
        )

        self.permissionService = PermissionService()
        self.accessibilityService = AccessibilityService()
        self.screenCaptureService = screenCaptureService
        self.launchAtLoginService = LaunchAtLoginService()

        self.windowService = windowService

        self.applicationService = ApplicationService(
            windowService: windowService
        )

        self.activationService = ApplicationActivationService()
        self.switcherPanelController = SwitcherPanelController()

        super.init()

        switcherPanelController.onItemClicked = { [weak self] index in
            self?.activateItemClickedByMouse(index: index)
        }
    }

    func start() {
        configureApplication()
        configureLaunchAtLogin()
        createStatusBarItem()
        checkPermissionsAndStartMonitoring()

        Logger.info("Application controller started.")
    }

    func stop() {
        keyboardMonitorService?.stop()
        keyboardMonitorService = nil

        switcherPanelController.hide()

        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }

        statusItem = nil
        launchAtLoginMenuItem = nil

        Logger.info("Application controller stopped.")
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateLaunchAtLoginMenuItem()
    }

    private func configureApplication() {
        NSApp.setActivationPolicy(.accessory)
    }

    private func configureLaunchAtLogin() {
        guard !launchAtLoginService.isEnabled else {
            Logger.info("Launch at login is already enabled.")
            return
        }

        let enabled = launchAtLoginService.enable()

        if enabled {
            Logger.info(
                "CommandTabSwitcher will automatically start at login."
            )
            return
        }

        if launchAtLoginService.requiresApproval {
            Logger.warning(
                "Launch at login is waiting for user approval."
            )

            launchAtLoginService.openSystemSettings()
        }
    }

    private func createStatusBarItem() {
        let item = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "rectangle.on.rectangle",
                accessibilityDescription: "Command Tab Switcher"
            )

            button.toolTip = Constants.Application.name
        }

        let menu = NSMenu()
        menu.delegate = self

        let statusMenuItem = NSMenuItem(
            title: "CommandTabSwitcher is running",
            action: nil,
            keyEquivalent: ""
        )

        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(.separator())

        let launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )

        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)

        launchAtLoginMenuItem = launchAtLoginItem
        updateLaunchAtLoginMenuItem()

        let loginItemsSettingsItem = NSMenuItem(
            title: "Open Login Items Settings",
            action: #selector(openLoginItemsSettings),
            keyEquivalent: ""
        )

        loginItemsSettingsItem.target = self
        menu.addItem(loginItemsSettingsItem)

        menu.addItem(.separator())

        let restartItem = NSMenuItem(
            title: "Restart Keyboard Monitoring",
            action: #selector(restartKeyboardMonitoring),
            keyEquivalent: ""
        )

        restartItem.target = self
        menu.addItem(restartItem)

        let screenPermissionItem = NSMenuItem(
            title: "Request Screen Recording Permission",
            action: #selector(requestScreenCapturePermission),
            keyEquivalent: ""
        )

        screenPermissionItem.target = self
        menu.addItem(screenPermissionItem)

        let openScreenSettingsItem = NSMenuItem(
            title: "Open Screen Recording Settings",
            action: #selector(openScreenRecordingSettings),
            keyEquivalent: ""
        )

        openScreenSettingsItem.target = self
        menu.addItem(openScreenSettingsItem)

        let accessibilityItem = NSMenuItem(
            title: "Open Accessibility Settings",
            action: #selector(openAccessibilitySettings),
            keyEquivalent: ""
        )

        accessibilityItem.target = self
        menu.addItem(accessibilityItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit CommandTabSwitcher",
            action: #selector(quitApplication),
            keyEquivalent: "q"
        )

        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        statusItem = item
    }

    private func updateLaunchAtLoginMenuItem() {
        guard let launchAtLoginMenuItem else {
            return
        }

        launchAtLoginMenuItem.state =
            launchAtLoginService.isEnabled ? .on : .off

        if launchAtLoginService.requiresApproval {
            launchAtLoginMenuItem.title =
                "Launch at Login — Approval Required"
        } else {
            launchAtLoginMenuItem.title = "Launch at Login"
        }
    }

    private func checkPermissionsAndStartMonitoring() {
        guard accessibilityService.isTrusted else {
            Logger.warning("Accessibility permission is missing.")
            permissionService.requestAccessibilityPermission()
            return
        }

        if !screenCaptureService.hasPermission {
            Logger.warning(
                "Screen Recording permission is missing."
            )

            screenCaptureService.requestPermission()
        }

        startKeyboardMonitoring()
    }

    private func startKeyboardMonitoring() {
        keyboardMonitorService?.stop()

        let service = KeyboardMonitorService(
            accessibilityService: accessibilityService
        ) { [weak self] event in
            self?.handleKeyboardEvent(event)
        }

        keyboardMonitorService = service

        if service.start() {
            Logger.info("Command+Tab interception is active.")
        } else {
            Logger.error(
                "Command+Tab interception could not be activated."
            )
        }
    }

    private func handleKeyboardEvent(
        _ event: KeyboardEvent
    ) {
        switch event {
        case .nextApplication:
            moveToNextItem()

        case .previousApplication:
            moveToPreviousItem()

        case .confirmSelection:
            confirmSelection()

        case .cancelSelection:
            cancelSelection()
        }
    }

    private func beginSwitcherSession(
        movingBackward: Bool
    ) {
        switcherItems = applicationService.fetchSwitcherItems()

        guard !switcherItems.isEmpty else {
            Logger.warning(
                "No visible application windows were found."
            )
            return
        }

        if movingBackward {
            selectedIndex = max(
                switcherItems.count - 1,
                0
            )
        } else {
            selectedIndex = switcherItems.count > 1 ? 1 : 0
        }

        switcherPanelController.show(
            items: switcherItems,
            selectedIndex: selectedIndex
        )
    }

    private func moveToNextItem() {
        guard switcherPanelController.isVisible else {
            beginSwitcherSession(
                movingBackward: false
            )
            return
        }

        guard !switcherItems.isEmpty else {
            return
        }

        selectedIndex =
            (selectedIndex + 1) % switcherItems.count

        switcherPanelController.updateSelection(
            selectedIndex: selectedIndex
        )

        Logger.info(
            "Selected \(switcherItems[selectedIndex].applicationName)."
        )
    }

    private func moveToPreviousItem() {
        guard switcherPanelController.isVisible else {
            beginSwitcherSession(
                movingBackward: true
            )
            return
        }

        guard !switcherItems.isEmpty else {
            return
        }

        selectedIndex =
            (selectedIndex - 1 + switcherItems.count)
            % switcherItems.count

        switcherPanelController.updateSelection(
            selectedIndex: selectedIndex
        )

        Logger.info(
            "Selected \(switcherItems[selectedIndex].applicationName)."
        )
    }

    private func confirmSelection() {
        guard switcherPanelController.isVisible,
              switcherItems.indices.contains(selectedIndex) else {
            resetSwitcherSession()
            return
        }

        let selectedItem = switcherItems[selectedIndex]

        switcherPanelController.hide { [weak self] in
            guard let self else {
                return
            }

            self.activationService.activate(selectedItem)
            self.resetSwitcherSession()
        }
    }

    private func cancelSelection() {
        switcherPanelController.hide { [weak self] in
            self?.resetSwitcherSession()
        }

        Logger.info("Application switching was cancelled.")
    }

    private func activateItemClickedByMouse(
        index: Int
    ) {
        guard switcherPanelController.isVisible,
              switcherItems.indices.contains(index) else {
            return
        }

        selectedIndex = index

        let selectedItem = switcherItems[index]

        Logger.info(
            "Mouse selected \(selectedItem.applicationName)."
        )

        switcherPanelController.hide { [weak self] in
            guard let self else {
                return
            }

            self.activationService.activate(selectedItem)
            self.resetSwitcherSession()
        }
    }

    private func resetSwitcherSession() {
        switcherItems.removeAll()
        selectedIndex = 0
    }

    @objc
    private func toggleLaunchAtLogin() {
        let changed = launchAtLoginService.toggle()

        updateLaunchAtLoginMenuItem()

        if changed {
            let message = launchAtLoginService.isEnabled
                ? "Launch at login is enabled."
                : "Launch at login is disabled."

            Logger.info(message)
            return
        }

        if launchAtLoginService.requiresApproval {
            Logger.warning(
                "Launch at login requires approval in System Settings."
            )

            launchAtLoginService.openSystemSettings()
        }
    }

    @objc
    private func openLoginItemsSettings() {
        launchAtLoginService.openSystemSettings()
    }

    @objc
    private func restartKeyboardMonitoring() {
        guard accessibilityService.isTrusted else {
            permissionService.requestAccessibilityPermission()
            return
        }

        startKeyboardMonitoring()
    }

    @objc
    private func requestScreenCapturePermission() {
        let granted = screenCaptureService.requestPermission()

        Logger.info(
            granted
                ? "Screen Recording permission is enabled."
                : "Screen Recording permission was requested."
        )
    }

    @objc
    private func openAccessibilitySettings() {
        permissionService.openAccessibilitySettings()
    }

    @objc
    private func openScreenRecordingSettings() {
        guard let url = URL(
            string: """
            x-apple.systempreferences:\
            com.apple.preference.security?Privacy_ScreenCapture
            """
        ) else {
            Logger.error(
                "Could not create the Screen Recording settings URL."
            )
            return
        }

        NSWorkspace.shared.open(url)
    }

    @objc
    private func quitApplication() {
        NSApp.terminate(nil)
    }
}