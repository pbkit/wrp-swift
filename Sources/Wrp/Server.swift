import Foundation
import Logging

public final class WrpServer {
    public let host: WrpHost
    private let configuration: Configuration

    public init(
        host: WrpHost,
        configuration: Configuration
    ) {
        self.host = host
        self.configuration = configuration
    }

    public func start() async throws {
        self.configuration.logger.trace("Trying to start host")
        try await self.host.start()
        self.configuration.logger.trace("Host started. Start listening")
        await self.listen()
        self.configuration.logger.trace("Gracefully finished")
    }

    public func listen() async {
        self.configuration.logger.info("Start listening")
        await withTaskGroup(of: Void.self) { taskGroup in
            for await context in host.listen() {
                var serverLogger = context.logger
                serverLogger[metadataKey: "stage"] = "server"

                serverLogger.info("Received context: \(context.methodName.fullName)")
                guard let serviceProvider = host.configuration.serviceProvidersByName[context.methodName.serviceName],
                      let handler = serviceProvider.handle(method: context.methodName.methodName, context: context)
                else {
                    var trailer = [
                        "wrp-status": "error",
                        "wrp-message": "Method not found: \(context.methodName.fullName)",
                    ]
                    context.sendHeader([:])
                    context.sendTrailer(&trailer)
                    serverLogger.info("Method not found: \(context.methodName.fullName)")
                    continue
                }

                let header = DeferStream<[String: String]>()
                let trailer = DeferStream<[String: String]>()
                let payload = DeferStream<Data>()

                taskGroup.addTask {
                    await handler.call(
                        header: header.continuation,
                        trailer: trailer.continuation,
                        payload: payload.continuation
                    )
                }

                taskGroup.addTask { [serverLogger] in
                    for await header in header.stream.prefix(1) {
                        serverLogger.trace("Send header \(header)")
                        context.sendHeader(header)
                    }
                    for await payload in payload.stream {
                        serverLogger.trace("Send payload \(payload.map { $0 })")
                        context.sendPayload(payload)
                    }
                    for await var trailer in trailer.stream.prefix(1) {
                        serverLogger.trace("Send trailer \(trailer)")
                        context.sendTrailer(&trailer)
                    }
                    serverLogger.info("Done \(context.methodName.fullName)")
                    // @TODO: Error handling on sending part
                }
            }
            taskGroup.cancelAll()
        }
        self.configuration.logger.info("End")
    }
}

public extension WrpServer {
    static func create(
        glue: WrpGlue,
        serviceProviders: [WrpHandlerProvider],
        logger: Logger = .init(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
    ) -> WrpServer {
        let host = WrpHost(
            channel: .init(socket: .init(glue: glue, configuration: .init(logger: logger)), configuration: .init(logger: logger)),
            configuration: .init(serviceProviders: serviceProviders, logger: logger)
        )
        return self.init(host: host, configuration: .init(serviceProviders: serviceProviders, logger: logger))
    }
}

public extension WrpServer {
    struct Configuration {
        public var logger: Logger
        public var serviceProviders: [WrpHandlerProvider]
        public init(
            serviceProviders: [WrpHandlerProvider],
            logger: Logger = .init(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        ) {
            self.logger = logger
            self.logger[metadataKey: "stage"] = "server"
            self.serviceProviders = serviceProviders
        }
    }
}
