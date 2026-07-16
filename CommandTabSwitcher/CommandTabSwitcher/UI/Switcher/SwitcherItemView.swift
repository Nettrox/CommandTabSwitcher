import AppKit

final class SwitcherItemView: NSView {
    var onClick: (() -> Void)?

    private let previewImageView = NSImageView()
    private let iconBackgroundView = NSVisualEffectView()
    private let iconImageView = NSImageView()
    private let applicationNameLabel = NSTextField(labelWithString: "")
    private let windowTitleLabel = NSTextField(labelWithString: "")

    private(set) var representedItem: SwitcherItem?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        with item: SwitcherItem,
        selected: Bool
    ) {
        representedItem = item

        previewImageView.image = item.previewImage
        iconImageView.image = item.applicationIcon

        applicationNameLabel.stringValue = item.applicationName

        windowTitleLabel.stringValue = item.windowTitle.isEmpty
            ? "Main Window"
            : item.windowTitle

        setSelected(
            selected,
            animated: false
        )
    }

    func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        let applyChanges = {
            self.layer?.borderWidth = selected ? 3 : 1

            self.layer?.borderColor = selected
                ? NSColor.controlAccentColor.cgColor
                : NSColor.white
                    .withAlphaComponent(0.12)
                    .cgColor

            self.layer?.shadowOpacity = selected ? 0.55 : 0.22
            self.layer?.shadowRadius = selected ? 24 : 12

            self.layer?.transform = selected
                ? CATransform3DMakeScale(1.035, 1.035, 1)
                : CATransform3DIdentity
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                context.timingFunction = CAMediaTimingFunction(
                    name: .easeOut
                )

                applyChanges()
            }
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            applyChanges()

            CATransaction.commit()
        }
    }

    override func layout() {
        super.layout()

        let horizontalPadding: CGFloat = 12
        let previewTopPadding: CGFloat = 12
        let previewHeight: CGFloat = 148

        previewImageView.frame = NSRect(
            x: horizontalPadding,
            y: bounds.height - previewTopPadding - previewHeight,
            width: bounds.width - horizontalPadding * 2,
            height: previewHeight
        )

        let iconSize: CGFloat = 52

        iconBackgroundView.frame = NSRect(
            x: previewImageView.frame.minX + 10,
            y: previewImageView.frame.maxY - iconSize - 10,
            width: iconSize,
            height: iconSize
        )

        iconImageView.frame = iconBackgroundView.bounds.insetBy(
            dx: 7,
            dy: 7
        )

        applicationNameLabel.frame = NSRect(
            x: horizontalPadding + 2,
            y: 34,
            width: bounds.width - horizontalPadding * 2 - 4,
            height: 22
        )

        windowTitleLabel.frame = NSRect(
            x: horizontalPadding + 2,
            y: 13,
            width: bounds.width - horizontalPadding * 2 - 4,
            height: 18
        )
    }

    override func mouseDown(with event: NSEvent) {
        onClick?()
    }

    override func resetCursorRects() {
        super.resetCursorRects()

        addCursorRect(
            bounds,
            cursor: .pointingHand
        )
    }

    private func configureView() {
        wantsLayer = true

        layer?.backgroundColor = NSColor(
            white: 0.075,
            alpha: 0.96
        ).cgColor

        layer?.cornerRadius = 20
        layer?.cornerCurve = .continuous

        layer?.borderWidth = 1
        layer?.borderColor = NSColor.white
            .withAlphaComponent(0.12)
            .cgColor

        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.22
        layer?.shadowRadius = 12
        layer?.shadowOffset = CGSize(
            width: 0,
            height: -4
        )
    }

    private func configureSubviews() {
        previewImageView.wantsLayer = true
        previewImageView.imageScaling = .scaleProportionallyUpOrDown
        previewImageView.imageAlignment = .alignCenter

        previewImageView.layer?.backgroundColor = NSColor(
            white: 0.025,
            alpha: 1
        ).cgColor

        previewImageView.layer?.cornerRadius = 14
        previewImageView.layer?.cornerCurve = .continuous
        previewImageView.layer?.masksToBounds = true

        iconBackgroundView.material = .hudWindow
        iconBackgroundView.blendingMode = .withinWindow
        iconBackgroundView.state = .active

        iconBackgroundView.wantsLayer = true
        iconBackgroundView.layer?.cornerRadius = 13
        iconBackgroundView.layer?.cornerCurve = .continuous
        iconBackgroundView.layer?.masksToBounds = true

        iconBackgroundView.layer?.borderWidth = 1
        iconBackgroundView.layer?.borderColor = NSColor.white
            .withAlphaComponent(0.22)
            .cgColor

        iconImageView.imageScaling = .scaleProportionallyUpOrDown

        applicationNameLabel.font = .systemFont(
            ofSize: 15,
            weight: .semibold
        )
        applicationNameLabel.textColor = .white
        applicationNameLabel.lineBreakMode = .byTruncatingTail
        applicationNameLabel.maximumNumberOfLines = 1

        windowTitleLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )
        windowTitleLabel.textColor = NSColor.white
            .withAlphaComponent(0.58)
        windowTitleLabel.lineBreakMode = .byTruncatingTail
        windowTitleLabel.maximumNumberOfLines = 1

        addSubview(previewImageView)
        addSubview(iconBackgroundView)

        iconBackgroundView.addSubview(iconImageView)

        addSubview(applicationNameLabel)
        addSubview(windowTitleLabel)
    }
}