import CoreGraphics
import Foundation

final class CommandTabEventTap {
    typealias EventHandler = (KeyboardEvent) -> Void

    private let eventHandler: EventHandler

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private var isCommandTabSessionActive = false

    init(eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }

    deinit {
        stop()
    }

    var isRunning: Bool {
        guard let eventTap else {
            return false
        }

        return CGEvent.tapIsEnabled(tap: eventTap)
    }

    @discardableResult
    func start() -> Bool {
        guard eventTap == nil else {
            return true
        }

        let eventMask =
            CGEventMask(1 << CGEventType.keyDown.rawValue)
            | CGEventMask(1 << CGEventType.keyUp.rawValue)
            | CGEventMask(1 << CGEventType.flagsChanged.rawValue)

        let callback: CGEventTapCallBack = {
            proxy,
            type,
            event,
            userInfo
            in

            guard let userInfo else {
                return Unmanaged.passUnretained(event)
            }

            let eventTap = Unmanaged<CommandTabEventTap>
                .fromOpaque(userInfo)
                .takeUnretainedValue()

            return eventTap.handleEvent(
                proxy: proxy,
                type: type,
                event: event
            )
        }

        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let createdEventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: userInfo
        ) else {
            Logger.error(
                "Could not create the keyboard event tap. Accessibility permission may be missing."
            )
            return false
        }

        guard let createdRunLoopSource = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            createdEventTap,
            0
        ) else {
            Logger.error("Could not create the event tap run loop source.")
            CFMachPortInvalidate(createdEventTap)
            return false
        }

        eventTap = createdEventTap
        runLoopSource = createdRunLoopSource

        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            createdRunLoopSource,
            .commonModes
        )

        CGEvent.tapEnable(
            tap: createdEventTap,
            enable: true
        )

        Logger.info("Global keyboard event tap started.")

        return true
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(
                tap: eventTap,
                enable: false
            )
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(
                CFRunLoopGetMain(),
                runLoopSource,
                .commonModes
            )
        }

        if let eventTap {
            CFMachPortInvalidate(eventTap)
        }

        eventTap = nil
        runLoopSource = nil
        isCommandTabSessionActive = false

        Logger.info("Global keyboard event tap stopped.")
    }

    private func handleEvent(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout,
             .tapDisabledByUserInput:

            reenableEventTap()
            return Unmanaged.passUnretained(event)

        case .keyDown:
            return handleKeyDown(event)

        case .keyUp:
            return handleKeyUp(event)

        case .flagsChanged:
            return handleFlagsChanged(event)

        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleKeyDown(
        _ event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(
            .keyboardEventKeycode
        )

        let modifierState = ModifierKeyState(
            flags: event.flags
        )

        if keyCode == Constants.Keyboard.tabKeyCode,
           modifierState.commandPressed {

            isCommandTabSessionActive = true

            if modifierState.shiftPressed {
                dispatch(.previousApplication)
            } else {
                dispatch(.nextApplication)
            }

            // Returning nil prevents the original macOS Command+Tab
            // switcher from receiving this event.
            return nil
        }

        if keyCode == Constants.Keyboard.escapeKeyCode,
           isCommandTabSessionActive {

            isCommandTabSessionActive = false
            dispatch(.cancelSelection)

            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func handleKeyUp(
        _ event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(
            .keyboardEventKeycode
        )

        if keyCode == Constants.Keyboard.tabKeyCode,
           isCommandTabSessionActive {

            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func handleFlagsChanged(
        _ event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        guard isCommandTabSessionActive else {
            return Unmanaged.passUnretained(event)
        }

        let modifierState = ModifierKeyState(
            flags: event.flags
        )

        if !modifierState.commandPressed {
            isCommandTabSessionActive = false
            dispatch(.confirmSelection)
        }

        return Unmanaged.passUnretained(event)
    }

    private func dispatch(_ keyboardEvent: KeyboardEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.eventHandler(keyboardEvent)
        }
    }

    private func reenableEventTap() {
        guard let eventTap else {
            return
        }

        CGEvent.tapEnable(
            tap: eventTap,
            enable: true
        )

        Logger.warning(
            "The keyboard event tap was disabled and has been re-enabled."
        )
    }
}