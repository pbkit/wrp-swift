import Foundation
import SwiftProtobuf

public protocol WrpClient {
    var guest: WrpGuest { get }
}

public extension WrpClient {
    func call<Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message>(
        path: String,
        request: AsyncStream<Request>,
        metadata: [String: String]? = nil
    ) throws -> WrpClientCall<Response> {
        guard let method = try? WrpRequestMethodIdentifier(identifier: path) else {
            throw WrpClientError.parseError(path)
        }
        let context = self.guest.request(
            method: method,
            request: AsyncStream<Data> { continuation in
                Task {
                    for await payload in request {
                        if let data = try? payload.serializedData() {
                            continuation.yield(data)
                        }
                    }
                    continuation.finish()
                }
            },
            metadata: metadata ?? [:]
        )
        return WrpClientCall(
            header: context.header.stream,
            response: AsyncStream<Response> { continuation in
                Task {
                    for await payload in context.payload.stream {
                        if let response = try? Response(contiguousBytes: payload) {
                            continuation.yield(response)
                        }
                    }
                    continuation.finish()
                }
            },
            trailer: context.trailer.stream
        )
    }
}

enum WrpClientError: Error {
    case parseError(String)
}

public struct WrpClientCall<
    Response: SwiftProtobuf.Message
> {
    var header: AsyncStream<[String: String]>
    var response: AsyncStream<Response>
    var trailer: AsyncStream<[String: String]>
}

public struct WrpClientCallOptions {
    public var customMetadata: [String: String]
}
