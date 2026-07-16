import Foundation

enum Constants {
    enum Application {
        static let name = "CommandTabSwitcher"
        static let bundleIdentifier = "com.irfanaksu.CommandTabSwitcher"
    }

    enum Keyboard {
        static let tabKeyCode: Int64 = 48
        static let escapeKeyCode: Int64 = 53
    }

    enum Animation {
        static let panelShowDuration: TimeInterval = 0.16
        static let panelHideDuration: TimeInterval = 0.12
        static let selectionDuration: TimeInterval = 0.10
    }

    enum Layout {
        static let panelWidth: CGFloat = 760
        static let panelHeight: CGFloat = 260
        static let panelCornerRadius: CGFloat = 22
        static let itemSpacing: CGFloat = 14
    }
}
