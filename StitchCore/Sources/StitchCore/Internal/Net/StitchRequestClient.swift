import Foundation
import BSON

/**
 * Returns the provided response if its status code is in the 200 range, throws a `StitchError` otherwise.
 */
private func inspectResponse(response: Response) throws -> Response {
    guard response.statusCode >= 200,
        response.statusCode < 300 else {
        throw StitchErrorCodable.handleError(forResponse: response)
    }

    return response
}

/**
 * A protocol defining the methods necessary to make requests to the Stitch server.
 */
public protocol StitchRequestClient {
    /**
     * Initializes the request client with the provided base URL and `Transport`.
     */
    init(baseURL: String, transport: Transport, defaultRequestTimeout: TimeInterval)

    /**
     * Performs a request against the Stitch server with the given `StitchRequest` object.
     *
     * - returns: the response to the request as a `Response` object.
     */
    func doRequest<R>(_ stitchReq: R) throws -> Response where R: StitchRequest

    /**
     * Performs a request against the Stitch server with the given `StitchDocRequest` object.
     *
     * - returns: the response to the request as a `Response` object.
     */
    func doJSONRequestRaw(_ stitchReq: StitchDocRequest) throws -> Response
}

/**
 * The implementation of `StitchRequestClient`.
 */
public final class StitchRequestClientImpl: StitchRequestClient {
    /**
     * The base URL of the Stitch server to which this client will make requests.
     */
    private let baseURL: String

    /**
     * The `Transport` which this client will use to make round trips to the Stitch server.
     */
    private let transport: Transport

    /**
     * The number of seconds that a `Transport` should spend by default on an HTTP round trip before failing with an
     * error.
     *
     * - important: If a request timeout was specified for a specific operation, for example in a function call, that
     *              timeout should override this one.
     */
    private let defaultRequestTimeout: TimeInterval

    /**
     * Initializes the request client with the provided base URL and `Transport`.
     */
    public init(baseURL: String, transport: Transport, defaultRequestTimeout: TimeInterval) {
        self.baseURL = baseURL
        self.transport = transport
        self.defaultRequestTimeout = defaultRequestTimeout
    }

    /**
     * Performs a request against the Stitch server with the given `StitchRequest` object.
     *
     * - returns: the response to the request as a `Response` object.
     */
    public func doRequest<R>(_ stitchReq: R) throws -> Response where R: StitchRequest {
        var response: Response!
        do {
            response = try self.transport.roundTrip(request: self.buildRequest(stitchReq))
        } catch {
            // Wrap the error from the transport in a `StitchError.requestError`
            throw StitchError.requestError(withError: error, withRequestErrorCode: .transportError)
        }
        return try inspectResponse(response: response)
    }

    /**
     * Performs a request against the Stitch server with the given `StitchDocRequest` object.
     *
     * - returns: the response to the request as a `Response` object.
     */
    public func doJSONRequestRaw(_ stitchReq: StitchDocRequest) throws -> Response {
        return try doRequest(StitchRequestBuilderImpl { builder in
            print(stitchReq.document.canonicalExtendedJSON)
            builder.body = stitchReq.document.canonicalExtendedJSON.data(using: .utf8)
            builder.headers = [
                Headers.contentType.rawValue: ContentTypes.applicationJson.rawValue
            ]
            builder.path = stitchReq.path
            builder.method = stitchReq.method
            builder.timeout = stitchReq.timeout
        }.build())
    }

    /**
     * Builds a plain HTTP request out of the provided `StitchRequest` object.
     */
    private func buildRequest<R>(_ stitchReq: R) throws -> Request where R: StitchRequest {
        return try RequestBuilder { builder in
            builder.method = stitchReq.method
            builder.url = "\(self.baseURL)\(stitchReq.path)"
            builder.timeout = stitchReq.timeout ?? self.defaultRequestTimeout
            builder.headers = stitchReq.headers
            builder.body = stitchReq.body
        }.build()
    }
}
