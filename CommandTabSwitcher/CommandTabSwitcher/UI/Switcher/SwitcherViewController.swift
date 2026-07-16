import AppKit

final class SwitcherViewController: NSViewController {
    var onItemClicked: ((Int) -> Void)? {
        didSet {
            switcherView.onItemClicked = onItemClicked
        }
    }

    private let switcherView = SwitcherView(
        frame: NSRect(
            x: 0,
            y: 0,
            width: 1320,
            height: 360
        )
    )

    override func loadView() {
        view = switcherView

        switcherView.onItemClicked = onItemClicked
    }

    func display(
        items: [SwitcherItem],
        selectedIndex: Int
    ) {
        switcherView.display(
            items: items,
            selectedIndex: selectedIndex
        )
    }

    func updateSelection(
        selectedIndex: Int
    ) {
        switcherView.updateSelection(
            selectedIndex: selectedIndex
        )
    }
}