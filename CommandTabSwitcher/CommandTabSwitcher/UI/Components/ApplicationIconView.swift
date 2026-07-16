import AppKit

final class ApplicationIconView: NSView {
    private let backgroundView = NSVisualEffectView()
    private let imageView = NSImageView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    func update(icon: NSImage) {
        imageView.image = icon
    }

    private func configureView() {
        wantsLayer = true

        layer?.cornerRadius = 12
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = true

        layer?.borderWidth = 1
        layer?.borderColor = NSColor.white
            .withAlphaComponent(0.18)
            .cgColor

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.material = .hudWindow
        backgroundView.blendingMode = .withinWindow
        backgroundView.state = .active

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyUpOrDown

        addSubview(backgroundView)
        addSubview(imageView)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            backgroundView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            backgroundView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            backgroundView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),

            imageView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 7
            ),
            imageView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -7
            ),
            imageView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 7
            ),
            imageView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -7
            )
        ])
    }
}