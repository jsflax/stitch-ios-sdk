import XCTest
@testable import StitchCoreSDK
import StitchCoreTestUtils

class StitchClientConfigurationUnitTests: XCTestCase {
    private let baseURL = "qux"
    private let dataDirectory = URL.init(string: "foo/bar")!
    private let storage = MemoryStorage.init()
    private let transport = FoundationHTTPTransport.init()
    private let defaultRequestTimeout: TimeInterval = testDefaultRequestTimeout

    func testStitchClientConfigurationBuilderImplInit() throws {
        let builder = StitchClientConfigurationBuilder()

        builder.with(baseURL: self.baseURL)
        builder.with(dataDirectory: self.dataDirectory)
        builder.with(storage: self.storage)
        builder.with(transport: self.transport)
        builder.with(defaultRequestTimeout: self.defaultRequestTimeout)

        let config = builder.build()

        XCTAssertEqual(config.baseURL, self.baseURL)
        XCTAssert(config.storage is MemoryStorage)
        XCTAssert(config.transport is FoundationHTTPTransport)
        XCTAssertEqual(config.defaultRequestTimeout, self.defaultRequestTimeout)
    }
}
