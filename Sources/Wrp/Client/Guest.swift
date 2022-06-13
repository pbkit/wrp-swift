import Foundation
import Logging

public final class WrpGuest {
    public let channel: WrpChannel
    public let availableMethodsDeferStream: DeferStream<Void> = .init()
    public var availableMethods: [WrpMethodIdentifier] = []
    private var requests: [String: RequestContext] = [:]
    private var requestIdCounter = 0
    private let configuration: Configuration
    public init(
        channel: WrpChannel,
        configuration: Configuration = .init()
    ) {
        self.channel = channel
        self.configuration = configuration
    }

    public func start() async throws {
        try await self.channel.socket.handshake()
    }

    public func listen() async {
        for await message in self.channel.listen() {
            guard message.message != nil else { continue }
            switch message.message {
            case .hostInitialize(let message):
                self.availableMethods = message.availableMethods.map { identifier in
                    try! WrpMethodIdentifier(identifier: identifier)
                }
                self.availableMethodsDeferStream.continuation.finish()
                continue
            case .hostError(let message):
                self.configuration.onError?(message.message)
                continue
            case .hostResStart(let message):
                if let request = self.requests[message.reqID] {
                    request.header.continuation.yield(message.header)
                    request.header.continuation.finish()
                }
                continue
            case .hostResPayload(let message):
                if let request = self.requests[message.reqID] {
                    request.payload.continuation.yield(message.payload)
                }
                continue
            case .hostResFinish(let message):
                if let request = self.requests[message.reqID] {
                    request.trailer.continuation.yield(message.trailer)
                    if message.trailer["wrp-status"] == "ok" {
                        request.payload.continuation.finish()
                    } else {
                        _ = message.trailer["wrp-message"] ?? ""
                        // @TODO: Make DeferStream with AsyncThrowingStream
                        request.payload.continuation.finish()
                    }
                }
                self.requests.removeValue(forKey: message.reqID)
                continue
            default:
                continue
            }
        }
    }

    public func request(
        method name: WrpMethodIdentifier,
        request payload: AsyncStream<Data>,
        metadata: [String: String]
    ) -> RequestContext {
        let requestId: String = {
            self.requestIdCounter += 1
            return "\(self.requestIdCounter)"
        }()
        self.channel.send(message: .with {
            $0.message = .guestReqStart(.with {
                $0.reqID = requestId
                $0.methodName = name.fullName
                $0.metadata = metadata
            })
        })
        Task {
            for await payload in payload {
                self.channel.send(message: .with {
                    $0.message = .guestReqPayload(.with {
                        $0.reqID = requestId
                        $0.payload = payload
                    })
                })
            }
            self.channel.send(message: .with {
                $0.message = .guestReqFinish(.with {
                    $0.reqID = requestId
                })
            })
        }
        return {
            let context: RequestContext = .init()
            self.requests[requestId] = context
            return context
        }()
    }
}

public struct RequestContext {
    var header: DeferStream<[String: String]> = .init()
    var payload: DeferStream<Data> = .init()
    var trailer: DeferStream<[String: String]> = .init()
}

public extension WrpGuest {
    enum GuestError: Error {
        case hostError(String)
    }
}

public extension WrpGuest {
    struct Configuration {
        public var logger: Logger
        public var onError: ((String) -> Void)?

        public init(logger: Logger = .init(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() }),
                    onError: ((String) -> Void)? = nil)
        {
            self.logger = logger
            self.logger[metadataKey: "stage"] = "guest"
            self.onError = onError
        }
    }
}
