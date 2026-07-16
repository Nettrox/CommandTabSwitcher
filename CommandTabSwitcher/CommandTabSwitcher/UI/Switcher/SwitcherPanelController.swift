import AppKit

final class SwitcherPanelController {
    var onItemClicked: ((Int) -> Void)?

    private let viewController: SwitcherViewController
    private let panel: SwitcherPanel

    private(set) var isVisible = false

    private let panelSize = NSSize(
        width: 1320,
        height: 360
    )

    init() {
        viewController = SwitcherViewController()

        panel = SwitcherPanel(
            contentRect: NSRect(
                origin: .zero,
                size: panelSize
            ),
            viewController: viewController
        )

        viewController.onItemClicked = { [weak self] index in
            self?.onItemClicked?(index)
        }
    }

    func show(
        items: [SwitcherItem],
        selectedIndex: Int
    ) {
        guard !items.isEmpty else {
            Logger.warning(
                "The switcher panel could not open because there are no items."
            )
            return
        }

        viewController.display(
            items: items,
            selectedIndex: selectedIndex
        )

        positionPanel()

        if isVisible {
            panel.orderFrontRegardless()
            return
        }

        isVisible = true

        let finalFrame = panel.frame

        let initialFrame = finalFrame.offsetBy(
            dx: 0,
            dy: -16
        )

        panel.alphaValue = 0

        panel.setFrame(
            initialFrame,
            display: false
        )

        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.16

            context.timingFunction = CAMediaTimingFunction(
                name: .easeOut
            )

            panel.animator().alphaValue = 1

            panel.animator().setFrame(
                finalFrame,
                display: true
            )
        }

        Logger.info(
            "Switcher panel displayed with \(items.count) items."
        )
    }

    func updateSelection(
        selectedIndex: Int
    ) {
        guard isVisible else {
            return
        }

        viewController.updateSelection(
            selectedIndex: selectedIndex
        )
    }

    func hide(
        completion: (() -> Void)? = nil
    ) {
        guard isVisible else {
            completion?()
            return
        }

        isVisible = false

        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.11

                context.timingFunction = CAMediaTimingFunction(
                    name: .easeIn
                )

                panel.animator().alphaValue = 0
            },
            completionHandler: { [weak self] in
                guard let self else {
                    completion?()
                    return
                }

                self.panel.orderOut(nil)
                self.panel.alphaValue = 1

                completion?()
            }
        )
    }

    private func positionPanel() {
        let mouseLocation = NSEvent.mouseLocation

        let targetScreen = NSScreen.screens.first {
            NSMouseInRect(
                mouseLocation,
                $0.frame,
                false
            )
        } ?? NSScreen.main ?? NSScreen.screens.first

        guard let screen = targetScreen else {
            Logger.error(
                "No screen was available for positioning the switcher panel."
            )
            return
        }

        let visibleFrame = screen.visibleFrame

        let origin = NSPoint(
            x: visibleFrame.midX - panelSize.width / 2,
            y: visibleFrame.midY - panelSize.height / 2
        )

        panel.setFrame(
            NSRect(
                origin: origin,
                size: panelSize
            ),
            display: false
        )
    }
}