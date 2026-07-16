import AppKit

final class SwitcherPanel: NSPanel {
    init(
        contentRect: NSRect,
        viewController: NSViewController
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .borderless,
                .nonactivatingPanel
            ],
            backing: .buffered,
            defer: false
        )

        contentViewController = viewController

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        level = .popUpMenu

        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .transient,
            .ignoresCycle
        ]

        acceptsMouseMovedEvents = true
        ignoresMouseEvents = false

        hidesOnDeactivate = false

        isMovable = false
        isMovableByWindowBackground = false

        animationBehavior = .none
        becomesKeyOnlyIfNeeded = true

        setContentSize(
            contentRect.size
        )
    }

    override var canBecomeKey: Bool {
        false
    }

    override var canBecomeMain: Bool {
        false
    }
}