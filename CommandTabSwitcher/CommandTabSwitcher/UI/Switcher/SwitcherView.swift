import AppKit

final class SwitcherView: NSView {
    var onItemClicked: ((Int) -> Void)?

    private let backgroundView = NSVisualEffectView()
    private let titleLabel = NSTextField(labelWithString: "Open Windows")
    private let scrollView = NSScrollView()
    private let documentView = FlippedView()

    private var cardViews: [SwitcherItemView] = []
    private var selectedIndex = 0

    private let cardWidth: CGFloat = 270
    private let cardHeight: CGFloat = 224
    private let cardSpacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 28

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(
        items: [SwitcherItem],
        selectedIndex: Int
    ) {
        removeExistingCards()

        self.selectedIndex = selectedIndex

        for (index, item) in items.enumerated() {
            let cardView = SwitcherItemView(
                frame: NSRect(
                    x: 0,
                    y: 0,
                    width: cardWidth,
                    height: cardHeight
                )
            )

            cardView.configure(
                with: item,
                selected: index == selectedIndex
            )

            cardView.onClick = { [weak self] in
                self?.handleCardClick(index: index)
            }

            documentView.addSubview(cardView)
            cardViews.append(cardView)
        }

        needsLayout = true
        layoutSubtreeIfNeeded()

        scrollToSelectedCard(
            animated: false
        )
    }

    func updateSelection(
        selectedIndex: Int
    ) {
        guard cardViews.indices.contains(selectedIndex) else {
            return
        }

        self.selectedIndex = selectedIndex

        for (index, cardView) in cardViews.enumerated() {
            cardView.setSelected(
                index == selectedIndex,
                animated: true
            )
        }

        scrollToSelectedCard(
            animated: true
        )
    }

    override func layout() {
        super.layout()

        backgroundView.frame = bounds

        titleLabel.frame = NSRect(
            x: 34,
            y: bounds.height - 46,
            width: bounds.width - 68,
            height: 24
        )

        scrollView.frame = NSRect(
            x: 0,
            y: 16,
            width: bounds.width,
            height: bounds.height - 68
        )

        let cardsWidth: CGFloat

        if cardViews.isEmpty {
            cardsWidth = 0
        } else {
            cardsWidth =
                CGFloat(cardViews.count) * cardWidth
                + CGFloat(cardViews.count - 1) * cardSpacing
        }

        let requiredWidth = max(
            scrollView.contentSize.width,
            cardsWidth + horizontalPadding * 2
        )

        documentView.frame = NSRect(
            x: 0,
            y: 0,
            width: requiredWidth,
            height: scrollView.contentSize.height
        )

        let cardsStartX: CGFloat

        if cardsWidth < scrollView.contentSize.width {
            cardsStartX =
                (scrollView.contentSize.width - cardsWidth) / 2
        } else {
            cardsStartX = horizontalPadding
        }

        let cardY = max(
            8,
            (documentView.bounds.height - cardHeight) / 2
        )

        for (index, cardView) in cardViews.enumerated() {
            cardView.frame = NSRect(
                x: cardsStartX
                    + CGFloat(index) * (cardWidth + cardSpacing),
                y: cardY,
                width: cardWidth,
                height: cardHeight
            )
        }
    }

    private func configureView() {
        wantsLayer = true

        layer?.cornerRadius = 28
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = true

        layer?.borderWidth = 1
        layer?.borderColor = NSColor.white
            .withAlphaComponent(0.15)
            .cgColor
    }

    private func configureSubviews() {
        backgroundView.material = .hudWindow
        backgroundView.blendingMode = .behindWindow
        backgroundView.state = .active

        titleLabel.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )

        titleLabel.textColor = NSColor.white
            .withAlphaComponent(0.92)

        scrollView.drawsBackground = false
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true

        scrollView.horizontalScrollElasticity = .none
        scrollView.verticalScrollElasticity = .none

        scrollView.documentView = documentView

        addSubview(backgroundView)
        addSubview(titleLabel)
        addSubview(scrollView)
    }

    private func handleCardClick(
        index: Int
    ) {
        guard cardViews.indices.contains(index) else {
            return
        }

        selectedIndex = index

        for (cardIndex, cardView) in cardViews.enumerated() {
            cardView.setSelected(
                cardIndex == index,
                animated: true
            )
        }

        onItemClicked?(index)
    }

    private func removeExistingCards() {
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }

        cardViews.removeAll()
    }

    private func scrollToSelectedCard(
        animated: Bool
    ) {
        guard cardViews.indices.contains(selectedIndex) else {
            return
        }

        let cardView = cardViews[selectedIndex]
        let clipView = scrollView.contentView

        let desiredX =
            cardView.frame.midX
            - clipView.bounds.width / 2

        let maximumX = max(
            0,
            documentView.bounds.width - clipView.bounds.width
        )

        let clampedX = min(
            max(0, desiredX),
            maximumX
        )

        let targetPoint = NSPoint(
            x: clampedX,
            y: 0
        )

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.16

                context.timingFunction = CAMediaTimingFunction(
                    name: .easeOut
                )

                clipView.animator().setBoundsOrigin(
                    targetPoint
                )
            }
        } else {
            clipView.setBoundsOrigin(
                targetPoint
            )
        }

        scrollView.reflectScrolledClipView(
            clipView
        )
    }
}

private final class FlippedView: NSView {
    override var isFlipped: Bool {
        true
    }
}