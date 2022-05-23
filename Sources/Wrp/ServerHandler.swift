import Foundation
import GRPC
import Logging
import SwiftProtobuf

public protocol WrpHandlerProvider: AnyObject {
    var serviceName: Substring { get }

    var methodNames: [Substring] { get }

    func handle(method: Substring, context: WrpRequestContext) -> WrpServerHandlerProtocol?
}

public protocol WrpServerHandlerProtocol {
    func call(
        header: AsyncStream<[String: String]>.Continuation,
        trailer: AsyncStream<[String: String]>.Continuation,
        payload: AsyncStream<Data>.Continuation
    ) async
}

public struct WrpRequestContext {
    let requestId: String
    let methodName: WrpRequestMethodIdentifier
    let metadata: [String: String]
    let request: AsyncStream<Data>
    let logger: Logger
    let sendHeader: (_ header: [String: String]) -> Void
    let sendPayload: (_ payload: Data) -> Void
    let sendTrailer: (_ trailer: inout [String: String]) -> Void
}

public class WrpRequestMethodIdentifier {
    let serviceName: Substring
    let methodName: Substring
    var fullName: String { "\(self.serviceName)/\(self.methodName)" }

    var description: String { self.fullName }

    init(identifier: String) throws {
        let splitted = identifier.split(separator: "/")
        guard let serviceName = splitted.first,
              let methodName = splitted.last
        else {
            throw SplitError.invalidInput(identifier)
        }
        self.serviceName = serviceName
        self.methodName = methodName
    }

    enum SplitError: Error {
        case invalidInput(String)
    }
}

public struct MethodHandlerContext<Response: SwiftProtobuf.Message> {
    public let sendHeader: (_ header: [String: String]) -> Void
    public let sendMessage: (_ message: Response) -> Void
    public let sendTrailer: (_ trailer: [String: String]) -> Void
}

public class WrpServerHandler<
    Request: SwiftProtobuf.Message,
    Response: SwiftProtobuf.Message
>: WrpServerHandlerProtocol {
    public typealias Serializer = ProtobufSerializer<Response>
    public typealias Deserializer = ProtobufDeserializer<Request>

    @usableFromInline
    internal let serializer: Serializer

    @usableFromInline
    internal let deserializer: Deserializer

    @usableFromInline
    internal let context: WrpRequestContext

    @usableFromInline
    internal let userFunction: (AsyncStream<Request>, MethodHandlerContext<Response>) async -> Void

    @inlinable
    public init(
        context: WrpRequestContext,
        requestDeserializer: Deserializer,
        responseSerializer: Serializer,
        userFunction: @escaping (AsyncStream<Request>, MethodHandlerContext<Response>) async -> Void
    ) {
        self.context = context
        self.deserializer = requestDeserializer
        self.serializer = responseSerializer
        self.userFunction = userFunction
    }

    public func call(
        header: AsyncStream<[String: String]>.Continuation,
        trailer: AsyncStream<[String: String]>.Continuation,
        payload: AsyncStream<Data>.Continuation
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
                    header.yield($0)
                    header.finish()
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
                    trailer.yield($0)
                    trailer.finish()
                    self.context.logger.trace("Send trailer \($0)")
                }
            )
        )
    }
}
