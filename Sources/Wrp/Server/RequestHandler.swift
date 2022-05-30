import Foundation
import GRPC
import Logging
import SwiftProtobuf

public protocol WrpRequestHandlerProtocol {
    func call(
        header: DeferJust<[String: String]>.Continuation,
        trailer: DeferJust<[String: String]>.Continuation,
        payload: DeferStream<Data>.Continuation
    ) async
}

public struct WrpRequestContext<Response: SwiftProtobuf.Message> {
    public let sendHeader: (_ header: [String: String]) -> Void
    public let sendMessage: (_ message: Response) -> Void
    public let sendTrailer: (_ trailer: [String: String]) -> Void
}

public class WrpRequestHandler<
    Request: SwiftProtobuf.Message,
    Response: SwiftProtobuf.Message
>: WrpRequestHandlerProtocol {
    public typealias Serializer = ProtobufSerializer<Response>
    public typealias Deserializer = ProtobufDeserializer<Request>

    @usableFromInline
    internal let serializer: Serializer

    @usableFromInline
    internal let deserializer: Deserializer

    @usableFromInline
    internal let context: WrpRequestHandlerContext

    @usableFromInline
    internal let userFunction: (AsyncStream<Request>, WrpRequestContext<Response>) async -> Void

    @inlinable
    public init(
        context: WrpRequestHandlerContext,
        requestDeserializer: Deserializer,
        responseSerializer: Serializer,
        userFunction: @escaping (AsyncStream<Request>, WrpRequestContext<Response>) async -> Void
    ) {
        self.context = context
        self.deserializer = requestDeserializer
        self.serializer = responseSerializer
        self.userFunction = userFunction
    }

    public func call(
        header: DeferJust<[String: String]>.Continuation,
        trailer: DeferJust<[String: String]>.Continuation,
        payload: DeferStream<Data>.Continuation
    ) async {
        let requestStream = AsyncStream<Request> { continuation in
            Task.init {
                for await data in context.request {
                    if let request = try? Request(contiguousBytes: data) {
                        continuation.yield(request)
                    }
                }
                continuation.finish()
            }
        }
        await self.userFunction(
            requestStream,
            .init(
                sendHeader: {
                    header.finish(with: $0)
                    self.context.logger.trace("Send header \($0)")
                },
                sendMessage: { message in
                    if let data = try? message.serializedData() {
                        self.context.logger.trace("Send message \(message)")
                        payload.yield(data)
                    }
                },
                sendTrailer: {
                    payload.finish()
                    trailer.finish(with: $0)
                    self.context.logger.trace("Send trailer \($0)")
                }
            )
        )
    }
}

public struct WrpRequestHandlerContext {
    let requestId: String
    let methodName: WrpMethodIdentifier
    let metadata: [String: String]
    let request: AsyncStream<Data>
    let logger: Logger
    let sendHeader: (_ header: [String: String]) -> Void
    let sendPayload: (_ payload: Data) -> Void
    let sendTrailer: (_ trailer: [String: String]) -> Void
}
