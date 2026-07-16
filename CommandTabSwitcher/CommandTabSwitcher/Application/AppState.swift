import Foundation

final class AppState {
    static let shared = AppState()

    private(set) var isSwitcherVisible = false
    private(set) var selectedIndex = 0
    private(set) var navigationCount = 0

    private init() {}

    func beginSwitching() {
        if !isSwitcherVisible {
            isSwitcherVisible = true
            selectedIndex = 0
            navigationCount = 0
        }
    }

    func selectNext() {
        beginSwitching()

        selectedIndex += 1
        navigationCount += 1
    }

    func selectPrevious() {
        beginSwitching()

        selectedIndex = max(0, selectedIndex - 1)
        navigationCount -= 1
    }

    func confirmSelection() {
        reset()
    }

    func cancelSelection() {
        reset()
    }

    private func reset() {
        isSwitcherVisible = false
        selectedIndex = 0
        navigationCount = 0
    }
}