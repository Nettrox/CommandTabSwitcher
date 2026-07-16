import AppKit

final class SelectionIndicatorView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    private func configureView() {
        wantsLayer = true

        layer?.cornerRadius = 18
        layer?.cornerCurve = .continuous

        layer?.borderWidth = 3
        layer?.borderColor = NSColor.controlAccentColor.cgColor

        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.45
        layer?.shadowRadius = 18
        layer?.shadowOffset = CGSize(
            width: 0,
            height: -4
        )
    }
}