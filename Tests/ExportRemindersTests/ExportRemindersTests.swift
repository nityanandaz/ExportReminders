import XCTest
import class Foundation.Bundle
import EventKit

final class ExportRemindersTests: XCTestCase {
    /// Test with Xcode.
    ///
    ///     $ swift test
    ///
    /// produces a failure. There, authorizationStatus equals .notDetermined.
    func testPermission() {
        XCTAssertFalse(
            EKEventStore.authorizationStatus(for: .reminder) == .authorized
        )
    }
    
    func testExample() throws {
        #warning("Update this test")
        
        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("export-reminders")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertNotEqual(output, "Hello, world!\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}

extension ExportRemindersTests {
    static var allTests = [
        ("testPermission", testPermission),
        ("testExample", testExample),
    ]
}
