import Foundation
import OSLog

enum Logger {
    private static let logger = os.Logger(
        subsystem: Constants.Application.bundleIdentifier,
        category: "Application"
    )

    static func debug(_ message: String) {
        print("[DEBUG] \(message)")
        logger.debug("\(message, privacy: .public)")
    }

    static func info(_ message: String) {
        print("[INFO] \(message)")
        logger.info("\(message, privacy: .public)")
    }

    static func warning(_ message: String) {
        print("[WARNING] \(message)")
        logger.warning("\(message, privacy: .public)")
    }

    static func error(_ message: String) {
        print("[ERROR] \(message)")
        logger.error("\(message, privacy: .public)")
    }
}