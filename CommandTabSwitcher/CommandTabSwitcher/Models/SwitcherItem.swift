import AppKit
import CoreGraphics

struct SwitcherItem {
    let windowID: CGWindowID
    let processIdentifier: pid_t

    let applicationName: String
    let windowTitle: String
    let bundleIdentifier: String?

    let applicationIcon: NSImage
    let previewImage: NSImage?

    let runningApplication: NSRunningApplication
}