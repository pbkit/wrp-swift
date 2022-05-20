import Wrp
import Foundation
import SwiftProtobuf
import GRPC

public protocol Pbkit_WrpTestServiceProvider: WrpHandlerProvider {
    var interceptors: Pbkit_Wrp_WrpTestServiceServerInterceptorFactoryProtocol? { get }
    func unary(request: AsyncStream<Pbkit_Wrp_WrpUnaryRequest>, context: MethodHandlerContext<Pbkit_Wrp_WrpUnaryResponse>)
}

extension Pbkit_WrpTestServiceProvider {
    public var serviceName: Substring { return "pbkit.wrp.WrpTestService" }
    
    public func handle(methodName: Substring, context: WrpRequestContext) -> WrpServerHandlerProtocol? {
        switch methodName {
        case "Unary":
            return WrpServerHandler(
                context: context,
                responseSerializer: ProtobufSerializer<Pbkit_Wrp_WrpUnaryResponse>(),
                requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_WrpUnaryRequest>(),
                userFunction: self.unary(request:context:)
            )
        default:
            return nil
        }
    }
}

class WrpTestServiceProvider: Pbkit_WrpTestServiceProvider {
    internal var interceptors: Pbkit_Wrp_WrpTestServiceServerInterceptorFactoryProtocol?
    
    init() {}
    
    func unary(
        request: AsyncStream<Pbkit_Wrp_WrpUnaryRequest>,
        context: MethodHandlerContext<Pbkit_Wrp_WrpUnaryResponse>
    ) {
        Task.init {
            context.sendHeader([:])
            for await req in request {
                print("WrpTestServiceProvider(Unary): Recv \(req.payload)")
            }
            context.sendMessage(.init())
            var trailer = ["hi": "hello"]
            context.sendTrailer(&trailer)
        }
    }
}
