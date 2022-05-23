import Foundation
import Logging
import SwiftProtobuf

public final class WrpHost {
    public let channel: WrpChannel
    public let configuration: Configuration
    private var requests: [String: DeferStream<Data>] = [:]

    public init(
        channel: WrpChannel,
        configuration: Configuration
    ) {
        self.channel = channel
        self.configuration = configuration
    }

    public func start() async throws {
        try await self.channel.socket.handshake()
        self.sendInitialize()
    }

    internal func sendInitialize() {
        self.channel.send(message: .with {
            $0.message = .hostInitialize(.with {
                $0.availableMethods = configuration.serviceProvidersByName.flatMap { (serviceName, serviceProvider) in
                    serviceProvider.methodNames.map { methodName in
                        serviceName + "/" + methodName
                    }
                }
            })
        })
    }

    public func listen() -> AsyncStream<WrpRequestContext> {
        return AsyncStream { continuation in
            Task.init {
                self.configuration.logger.info("Start listening")
                for await message in self.channel.listen() {
                    self.configuration.logger.debug("Received \(message)")
                    guard message.message != nil else {
                        self.configuration.logger.error("Received null message")
                        self.channel.send(message: .with {
                            $0.message = .hostError(
                                .with {
                                    $0.message = "Received null message"
                                }
                            )
                        })
                        continue
                    }
                    switch message.message {
                    case .hostInitialize,
                         .hostResStart,
                         .hostResPayload,
                         .hostResFinish:
                        continue
                    case .guestReqStart(let request):
                        let requestStream = DeferStream<Data>()
                        self.requests[request.reqID] = requestStream
                        guard let methodName = try? WrpRequestMethodIdentifier(identifier: request.methodName) else {
                            self.configuration.logger.error("Invalid methodName \(request.methodName)")
                            continue
                        }
                        var contextLogger = self.configuration.logger
                        contextLogger[metadataKey: "stage"] = "Request"
                        contextLogger[metadataKey: "requestId"] = "\(request.reqID)"
                        let context = WrpRequestContext(
                            requestId: request.reqID,
                            methodName: methodName,
                            metadata: request.metadata,
                            request: requestStream.stream,
                            logger: contextLogger,
                            sendHeader: { header in
                                let message = Pbkit_Wrp_WrpMessage.with {
                                    $0.message = .hostResStart(.with {
                                        $0.reqID = request.reqID
                                        $0.header = header
                                    })
                                }
                                self.channel.send(message: message)
                                contextLogger.debug("send/header: \(message)")
                            },
                            sendPayload: { payload in
                                let message = Pbkit_Wrp_WrpMessage.with {
                                    $0.message = .hostResPayload(.with {
                                        $0.reqID = request.reqID
                                        $0.payload = payload
                                    })
                                }
                                self.channel.send(message: message)
                                contextLogger.debug("send/payload: \(message)")
                            },
                            sendTrailer: { trailer in
                                if trailer["wrp-status"] == nil { trailer["wrp-status"] = "ok" }
                                if trailer["wrp-message"] == nil { trailer["wrp-message"] = "" }
                                let message = Pbkit_Wrp_WrpMessage.with {
                                    $0.message = .hostResFinish(.with {
                                        $0.reqID = request.reqID
                                        $0.trailer = trailer
                                    })
                                }
                                self.channel.send(message: message)
                                contextLogger.debug("send/trailer: \(message)")
                            }
                        )
                        continuation.yield(context)
                    case .guestReqPayload(let request):
                        if let requestStream = self.requests[request.reqID] {
                            requestStream.continuation?.yield(request.payload)
                        } else {
                            self.channel.send(message: .with {
                                $0.message = .hostError(.with {
                                    $0.message = "Received unexpected request payload for { reqId: \(request.reqID) }"
                                })
                            })
                            self.configuration.logger.error("Received unexpected request payload for { reqId: \(request.reqID) }")
                        }
                    case .guestReqFinish(let request):
                        if let requestStream = self.requests[request.reqID] {
                            requestStream.continuation?.finish()
                            self.requests.removeValue(forKey: request.reqID)
                        } else {
                            self.channel.send(message: .with {
                                $0.message = .hostError(.with {
                                    $0.message = "Received unexpected request finish for { reqId: \(request.reqID) }"
                                })
                            })
                            self.configuration.logger.error("Received unexpected request finish for { reqId: \(request.reqID) }")
                        }
                        continue
                    default:
                        continue
                    }
                }
                continuation.finish()
                self.configuration.logger.info("End")
            }
        }
    }
}

public extension WrpHost {
    struct Configuration {
        public var logger = Logger(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        internal var serviceProvidersByName: [Substring: WrpHandlerProvider]
        public var serviceProviders: [WrpHandlerProvider] {
            get {
                return Array(self.serviceProvidersByName.values)
            }
            set {
                self.serviceProvidersByName = Dictionary(
                    uniqueKeysWithValues: newValue.map { ($0.serviceName, $0) }
                )
            }
        }

        public init(
            serviceProviders: [WrpHandlerProvider],
            logger: Logger = Logger(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        ) {
            self.serviceProvidersByName = Dictionary(uniqueKeysWithValues: serviceProviders
                .map { ($0.serviceName, $0) }
            )
            self.logger = logger
            self.logger[metadataKey: "stage"] = "host"
        }
    }
}
