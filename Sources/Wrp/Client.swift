import Foundation
import SwiftProtobuf

public protocol WrpClient {
    var guest: WrpGuest { get }
}

public extension WrpClient {
    func makeUnaryCall<
        Request: SwiftProtobuf.Message,
        Response: SwiftProtobuf.Message
    >(
        path: String,
        request: Request,
        metadata: [String: String] = [:]
    ) throws -> WrpUnaryResponse<Response> {
        guard let method = try?
                WrpRequestMethodIdentifier(identifier: path) else {
            throw WrpClientError.parseError(path)
        }
        let context = self.guest.request(
            method: method,
            request: AsyncStream<Data> {
                guard let data = try? request.serializedData() else {
                    return nil
                }
                return data
            },
            metadata: metadata
        )
        let header = DeferJust<[String: String]>()
        let response = DeferJust<Response>()
        let trailer = DeferJust<[String: String]>()

        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        header.reject()
                        return
                    }
                    header.resolve(value)
                }
                taskGroup.addTask {
                    guard let data = await context.payload.stream.first(),
                          let message = try? Response.init(contiguousBytes: data) else {
                        response.reject()
                        return
                    }
                    response.resolve(message)
                }
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        trailer.reject()
                        return
                    }
                    trailer.resolve(value)
                }
            }
        }
        
        return WrpUnaryResponse(
            header: header.toJust(),
            response: response.toJust(),
            trailer: trailer.toJust()
        )
    }
    
    func makeClientStreamingCall<
        Request: SwiftProtobuf.Message,
        Response: SwiftProtobuf.Message
    >(
        path: String,
        request: AsyncStream<Request>,
        metadata: [String: String] = [:]
    ) throws -> WrpUnaryResponse<Response> {
        guard let method = try?
                WrpRequestMethodIdentifier(identifier: path) else {
            throw WrpClientError.parseError(path)
        }
        let context = self.guest.request(
            method: method,
            request: request.compactMap { message in
                if let data = try? message.serializedData() {
                    return data
                }
                return nil
            }.toAsyncStream(),
            metadata: metadata
        )
        let header = DeferJust<[String: String]>()
        let response = DeferJust<Response>()
        let trailer = DeferJust<[String: String]>()

        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        header.reject()
                        return
                    }
                    header.resolve(value)
                }
                taskGroup.addTask {
                    guard let data = await context.payload.stream.first(),
                          let message = try? Response.init(contiguousBytes: data) else {
                        response.reject()
                        return
                    }
                    response.resolve(message)
                }
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        trailer.reject()
                        return
                    }
                    trailer.resolve(value)
                }
            }
        }
        
        return WrpUnaryResponse(
            header: header.toJust(),
            response: response.toJust(),
            trailer: trailer.toJust()
        )
    }
    
    func makeServerStreamingCall<
        Request: SwiftProtobuf.Message,
        Response: SwiftProtobuf.Message
    >(
        path: String,
        request: Request,
        metadata: [String: String] = [:]
    ) throws -> WrpStreamingResponse<Response> {
        guard let method = try?
                WrpRequestMethodIdentifier(identifier: path) else {
            throw WrpClientError.parseError(path)
        }
        let context = self.guest.request(
            method: method,
            request: AsyncStream<Data> {
                guard let data = try? request.serializedData() else {
                    return nil
                }
                return data
            },
            metadata: metadata
        )
        let header = DeferJust<[String: String]>()
        let response = context.payload.stream.compactMap { (payload) -> Response? in
            guard let payload = try? Response.init(contiguousBytes: payload) else {
                return nil
            }
            return payload
        }.toAsyncStream()
        let trailer = DeferJust<[String: String]>()

        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        header.reject()
                        return
                    }
                    header.resolve(value)
                }
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        trailer.reject()
                        return
                    }
                    trailer.resolve(value)
                }
            }
        }
        
        return WrpStreamingResponse(
            header: header.toJust(),
            response: response,
            trailer: trailer.toJust()
        )
    }
    
    func makeBidirectionalStreamingCall<
        Request: SwiftProtobuf.Message,
        Response: SwiftProtobuf.Message
    >(
        path: String,
        request: AsyncStream<Request>,
        metadata: [String: String] = [:]
    ) throws -> WrpStreamingResponse<Response> {
        guard let method = try?
                WrpRequestMethodIdentifier(identifier: path) else {
            throw WrpClientError.parseError(path)
        }
        let context = self.guest.request(
            method: method,
            request: request.compactMap { message in
                if let data = try? message.serializedData() {
                    return data
                }
                return nil
            }.toAsyncStream(),
            metadata: metadata
        )
        let header = DeferJust<[String: String]>()
        let response = context.payload.stream.compactMap { (payload) -> Response? in
            guard let payload = try? Response.init(contiguousBytes: payload) else {
                return nil
            }
            return payload
        }.toAsyncStream()
        let trailer = DeferJust<[String: String]>()

        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        header.reject()
                        return
                    }
                    header.resolve(value)
                }
                taskGroup.addTask {
                    guard let value = await context.header.stream.first() else {
                        trailer.reject()
                        return
                    }
                    trailer.resolve(value)
                }
            }
        }
        
        return WrpStreamingResponse(
            header: header.toJust(),
            response: response,
            trailer: trailer.toJust()
        )
    }
}

enum WrpClientError: Error {
    case parseError(String)
}

public struct WrpClientCall<
    Response: SwiftProtobuf.Message
> {
    var header: AsyncStream<[String: String]>
    var response: AsyncStream<Response>
    var trailer: AsyncStream<[String: String]>
}

public struct WrpClientCallOptions {
    public var customMetadata: [String: String]
}

public struct WrpUnaryResponse<
    Response: SwiftProtobuf.Message
> {
    var header: Just<[String: String]>
    var response: Just<Response>
    var trailer: Just<[String: String]>
}

public struct WrpStreamingResponse<
    Response: SwiftProtobuf.Message
> {
    var header: Just<[String: String]>
    var response: AsyncStream<Response>
    var trailer: Just<[String: String]>
}
