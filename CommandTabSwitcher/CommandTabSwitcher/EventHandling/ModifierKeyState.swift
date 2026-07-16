import CoreGraphics

struct ModifierKeyState {
    let commandPressed: Bool
    let shiftPressed: Bool
    let optionPressed: Bool
    let controlPressed: Bool

    init(flags: CGEventFlags) {
        commandPressed = flags.contains(.maskCommand)
        shiftPressed = flags.contains(.maskShift)
        optionPressed = flags.contains(.maskAlternate)
        controlPressed = flags.contains(.maskControl)
    }
}