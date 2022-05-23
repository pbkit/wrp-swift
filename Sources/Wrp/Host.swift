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
                print("WrpHost(listen): Start")
                for await message in self.channel.listen() {
                    print("WrpHost(listen): Recv \(message)")
                    guard message.message != nil else {
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
                    case .guestReqStart(let req):
                        print("WrpHost(listen/GuestReqStart): \(req)")
                        let requestStream = DeferStream<Data>()
                        self.requests[req.reqID] = requestStream
                        guard let methodName = try? WrpRequestMethodIdentifier(identifier: req.methodName) else {
                            print("WrpHost(error): Invalid methodName \(req.methodName)")
                            continue
                        }
                        let wrpRequest = WrpRequestContext(
                            methodName: methodName,
                            metadata: req.metadata,
                            request: requestStream.stream,
                            sendHeader: { header in
                                self.channel.send(message: .with {
                                    $0.message = .hostResStart(.with {
                                        $0.reqID = req.reqID
                                        $0.header = header
                                    })
                                })
                            },
                            sendPayload: { payload in
                                self.channel.send(message: .with {
                                    $0.message = .hostResPayload(.with {
                                        $0.reqID = req.reqID
                                        $0.payload = payload
                                    })
                                })
                            },
                            sendTrailer: { trailer in
                                if trailer["wrp-status"] == nil { trailer["wrp-status"] = "ok" }
                                if trailer["wrp-message"] == nil { trailer["wrp-message"] = "" }
                                self.channel.send(message: .with {
                                    $0.message = .hostResFinish(.with {
                                        $0.reqID = req.reqID
                                        $0.trailer = trailer
                                    })
                                })
                            }
                        )
                        continuation.yield(wrpRequest)
                    case .guestReqPayload(let req):
                        print("WrpHost(listen/GuestReqPayload): \(req)")
                        if let requestStream = self.requests[req.reqID] {
                            requestStream.continuation?.yield(req.payload)
                        } else {
                            self.channel.send(message: .with {
                                $0.message = .hostError(.with {
                                    $0.message = "Received unexpected request payload for { reqId: \(req.reqID) }"
                                })
                            })
                        }
                    case .guestReqFinish(let req):
                        print("WrpHost(listen/GuestReqFinish): \(req)")
                        if let requestStream = self.requests[req.reqID] {
                            requestStream.continuation?.finish()
                            self.requests.removeValue(forKey: req.reqID)
                        } else {
                            self.channel.send(message: .with {
                                $0.message = .hostError(.with {
                                    $0.message = "Received unexpected request finish for { reqId: \(req.reqID) }"
                                })
                            })
                        }
                        continue
                    default:
                        continue
                    }
                }
                continuation.finish()
                print("WrpHost(listen): End")
            }
        }
    }
}

public extension WrpHost {
    struct Configuration {
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

        public var logger = Logger(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        internal var serviceProvidersByName: [Substring: WrpHandlerProvider]

        public init(
            serviceProviders: [WrpHandlerProvider],
            logger: Logger = Logger(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        ) {
            self.serviceProvidersByName = Dictionary(uniqueKeysWithValues: serviceProviders
                .map { ($0.serviceName, $0) }
            )
            self.logger = logger
        }
    }
}
