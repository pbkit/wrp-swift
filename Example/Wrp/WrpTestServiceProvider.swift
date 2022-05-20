import Wrp
import Foundation
import SwiftProtobuf
import GRPC

public protocol Pbkit_WrpExampleServiceProvider: WrpHandlerProvider {
    var interceptors: Pbkit_Wrp_Example_WrpExampleServiceServerInterceptorFactoryProtocol? { get }
    
    func getTextValue(request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>, context: MethodHandlerContext<Pbkit_Wrp_Example_GetTextValueResponse>)

    func getSliderValue(request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>, context: MethodHandlerContext<Pbkit_Wrp_Example_GetSliderValueResponse>)
}

extension Pbkit_WrpExampleServiceProvider {
    public var serviceName: Substring { return "pbkit.wrp.example.WrpExampleService" }
    
    public var methodNames: [Substring] { return ["GetTextValue", "GetSliderValue"] }
    
    public func handle(methodName: Substring, context: WrpRequestContext) -> WrpServerHandlerProtocol? {
        switch methodName {
        case "GetTextValue":
            return WrpServerHandler(
                context: context,
                responseSerializer: ProtobufSerializer<Pbkit_Wrp_Example_GetTextValueResponse>(),
                requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_Example_GetTextValueRequest>(),
                userFunction: self.getTextValue(request:context:)
            )
        case "GetSliderValue":
            return WrpServerHandler(
                context: context,
                responseSerializer: ProtobufSerializer<Pbkit_Wrp_Example_GetSliderValueResponse>(),
                requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_Example_GetSliderValueRequest>(),
                userFunction: self.getSliderValue(request:context:)
            )
        default:
            return nil
        }
    }
}

class WrpExampleServiceProvider: Pbkit_WrpExampleServiceProvider {
    internal var interceptors: Pbkit_Wrp_Example_WrpExampleServiceServerInterceptorFactoryProtocol?
    
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

public protocol Pbkit_Wrp_Example_WrpExampleServiceServerInterceptorFactoryProtocol {
  func makeGetTextValueInterceptors() -> [ServerInterceptor<Pbkit_Wrp_Example_GetTextValueRequest, Pbkit_Wrp_Example_GetTextValueResponse>]

  func makeGetSliderValueInterceptors() -> [ServerInterceptor<Pbkit_Wrp_Example_GetSliderValueRequest, Pbkit_Wrp_Example_GetSliderValueResponse>]
}
