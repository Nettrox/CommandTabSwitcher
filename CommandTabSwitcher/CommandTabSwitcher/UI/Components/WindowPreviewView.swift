import AppKit

final class WindowPreviewView: NSView {
    private let imageView = NSImageView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
        configureImageView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
        configureImageView()
    }

    func update(image: NSImage?) {
        imageView.image = image

        if image == nil {
            layer?.backgroundColor = NSColor(
                white: 0.15,
                alpha: 1
            ).cgColor
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
        }
    }

    private func configureView() {
        wantsLayer = true

        layer?.cornerRadius = 14
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = true

        layer?.backgroundColor = NSColor(
            white: 0.10,
            alpha: 1
        ).cgColor
    }

    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageAlignment = .alignCenter

        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            imageView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}