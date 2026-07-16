import AppKit
import CoreGraphics

final class ScreenCaptureService {
    var hasPermission: Bool {
        CGPreflightScreenCaptureAccess()
    }

    @discardableResult
    func requestPermission() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    func captureWindow(
        windowID: CGWindowID
    ) -> NSImage? {
        guard windowID != 0 else {
            return nil
        }

        guard let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [
                .boundsIgnoreFraming,
                .bestResolution
            ]
        ) else {
            Logger.warning(
                "Could not capture window \(windowID)."
            )

            return nil
        }

        guard cgImage.width > 1,
              cgImage.height > 1 else {
            return nil
        }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(
                width: cgImage.width,
                height: cgImage.height
            )
        )
    }
}