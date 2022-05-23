import Foundation
import Logging

public class WrpChannel {
    public var socket: WrpSocket
    private let configuration: Configuration

    public init(
        socket: WrpSocket,
        configuration: Configuration = .init()
    ) {
        self.socket = socket
        self.configuration = configuration
    }

    public func listen() -> AsyncStream<Pbkit_Wrp_WrpMessage> {
        AsyncStream { continuation in
            Task.init {
                self.configuration.logger.debug("Start listening")
                for await var packet in self.socket.read() {
                    let length = packet.popFirst(4).reversed().reduce(0) { acc, curr in
                        acc << 4 + curr
                    }
                    let payload = packet.popFirst(Int(length))
                    guard let message = try? Pbkit_Wrp_WrpMessage(contiguousBytes: payload) else {
                        continuation.yield(.init())
                        continue
                    }
                    continuation.yield(message)
                }
                continuation.finish()
                self.configuration.logger.debug("End")
            }
        }
    }

    public func send(message: Pbkit_Wrp_WrpMessage) {
        guard let payload = try? message.serializedData() else {
            return
        }
        let lengthU8s = UInt32(payload.count).littleEndian
        let length = withUnsafeBytes(of: lengthU8s) {
            Data($0)
        }
        var packet = Data()
        packet.append(length)
        packet.append(payload)
        self.configuration.logger.debug("Send: \(packet.map { $0 })")
        self.socket.write(packet)
    }
}

public extension WrpChannel {
    class Configuration {
        public var logger: Logger
        public init(
            logger: Logger = .init(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() }))
        {
            self.logger = logger
            self.logger[metadataKey: "stage"] = "channel"
        }
    }
}
