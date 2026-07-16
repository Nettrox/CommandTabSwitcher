import ApplicationServices

final class AccessibilityService {
    var isTrusted: Bool {
        AXIsProcessTrusted()
    }
}
