import Foundation

public final class WrpServer {
    public let host: WrpHost
    
    public init(host: WrpHost) {
        self.host = host
    }
    
    public static func create(configuration: WrpHost.Configuration) -> WrpServer {
        let host: WrpHost = .init(channel: .init(socket: .init(glue: .init())), configuration: configuration)
        return self.init(host: host)
    }
    
    public func start() async {
        print("WrpServer(start): Trying to start host")
        await self.host.start()
        print("WrpServer(start): Host started. server listening")
        await self.listen()
        print("WrpServer(start): End")
    }
    
    public func listen() async {
        print("WrpServer(listen): Start")
        for await context in host.listen() {
            print("WrpServer(listen): Context recv \(context.methodName)")
            guard let serviceProvider = host.configuration.serviceProvidersByName[context.methodName.serviceName],
                  let result = serviceProvider.handle(methodName: context.methodName.methodName, context: context)?.call() else {
                var trailer = [
                    "wrp-status": "error",
                    "wrp-message": "Method not found: \(context.methodName)"
                ]
                context.sendHeader([:])
                context.sendTrailer(&trailer)
                continue
            }
            
            for await header in result.header.prefix(1) {
                print("WrpServer(listen): header")
                context.sendHeader(header)
            }
            for await payload in result.payload {
                print("WrpServer(listen): payload")
                context.sendPayload(payload)
            }
            for await var trailer in result.trailer.prefix(1) {
                print("WrpServer(listen): trailer")
                context.sendTrailer(&trailer)
            }
            print("WrpServer(listen): Done \(context.methodName)")
            // @TODO: Error handling on sending part
        }
        print("WrpServer(listen): End")
    }
}

