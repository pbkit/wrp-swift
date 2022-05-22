import Foundation

public final class WrpServer {
    public let host: WrpHost
    
    public init(host: WrpHost) {
        self.host = host
    }
    
    public static func create(glue: WrpGlue, configuration: WrpHost.Configuration) -> WrpServer {
        let host: WrpHost = .init(channel: .init(socket: .init(glue: glue)), configuration: configuration)
        return self.init(host: host)
    }
    
    public func start() async throws {
        print("WrpServer(start): Trying to start host")
        try await self.host.start()
        print("WrpServer(start): Host started. server listening")
        await self.listen()
        print("WrpServer(start): Gracefully finished")
    }
    
    public func listen() async {
        print("WrpServer(listen): Start")
        await withTaskGroup(of: Void.self) { taskGroup in
            for await context in host.listen() {
                print("WrpServer(listen): Context recv \(context.methodName.fullName)")
                guard let serviceProvider = host.configuration.serviceProvidersByName[context.methodName.serviceName],
                      let handler = serviceProvider.handle(methodName: context.methodName.methodName, context: context) else {
                    var trailer = [
                        "wrp-status": "error",
                        "wrp-message": "Method not found: \(context.methodName.fullName)"
                    ]
                    context.sendHeader([:])
                    context.sendTrailer(&trailer)
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
                
                taskGroup.addTask {
                    for await header in header.stream.prefix(1) {
                        print("WrpServer(send): header \(header)")
                        context.sendHeader(header)
                    }
                    for await payload in payload.stream {
                        print("WrpServer(send): payload \(payload.map { $0 })")
                        context.sendPayload(payload)
                    }
                    for await var trailer in trailer.stream.prefix(1) {
                        print("WrpServer(send): trailer \(trailer)")
                        context.sendTrailer(&trailer)
                    }
                    print("WrpServer(listen): Done \(context.methodName.fullName)")
                    // @TODO: Error handling on sending part
                }
            }
            taskGroup.cancelAll()
        }
        print("WrpServer(listen): End")
    }
}

