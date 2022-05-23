import Foundation

public class WrpChannel {
    public var socket: WrpSocket

    init(socket: WrpSocket) {
        self.socket = socket
    }

    public func listen() -> AsyncStream<Pbkit_Wrp_WrpMessage> {
        AsyncStream { continuation in
            Task.init {
                print("WrpChannel(listen): Start")
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
                print("WrpChannel(listen): End")
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
        print("WrpChannel(send): \(packet.map { $0 })")
        self.socket.write(packet)
    }
}
