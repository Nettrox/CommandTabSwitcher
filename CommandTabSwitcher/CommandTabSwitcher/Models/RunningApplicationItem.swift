import AppKit

struct RunningApplicationItem {
    let processIdentifier: pid_t
    let name: String
    let bundleIdentifier: String?
    let icon: NSImage
    let application: NSRunningApplication
}