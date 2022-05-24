import GRPC
import SwiftProtobuf
import Wrp

public protocol Pbkit_Wrp_Example_WrpExampleServiceWrpClientProtocol: WrpClient {
    func getTextValue(_ request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>) throws -> WrpClientCall<Pbkit_Wrp_Example_GetTextValueResponse>
    
    func getSliderValue(_ request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>) throws -> WrpClientCall<Pbkit_Wrp_Example_GetSliderValueResponse>
}

extension Pbkit_Wrp_Example_WrpExampleServiceWrpClientProtocol {
    internal func getTextValue(
        _ request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>,
        callOptions: WrpClientCallOptions?
    ) throws -> WrpClientCall<Pbkit_Wrp_Example_GetTextValueResponse> {
        return try self.call(path: "pbkit.wrp.example.WrpExampleService/GetTextValue", request: request)
    }
    
    internal func getSliderValue(
        _ request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>,
        callOptions: WrpClientCallOptions?
    ) throws -> WrpClientCall<Pbkit_Wrp_Example_GetSliderValueResponse> {
        return try self.call(path: "pbkit.wrp.example.WrpExampleService/GetSliderValue", request: request)
    }
}

public protocol Pbkit_Wrp_Example_WrpExampleServiceWrpProvider: WrpHandlerProvider {
    func getTextValue(request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>, context: MethodHandlerContext<Pbkit_Wrp_Example_GetTextValueResponse>) async

    func getSliderValue(request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>, context: MethodHandlerContext<Pbkit_Wrp_Example_GetSliderValueResponse>) async
}

public extension Pbkit_Wrp_Example_WrpExampleServiceWrpProvider {
    var serviceName: Substring { return "pbkit.wrp.example.WrpExampleService" }

    var methodNames: [Substring] { return ["GetTextValue", "GetSliderValue"] }

    func handle(
        method name: Substring,
        context: WrpRequestContext
    ) -> WrpServerHandlerProtocol? {
        switch name {
        case "GetTextValue":
            return WrpServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_Example_GetTextValueRequest>(),
                responseSerializer: ProtobufSerializer<Pbkit_Wrp_Example_GetTextValueResponse>(),
                userFunction: self.getTextValue(request:context:)
            )

        case "GetSliderValue":
            return WrpServerHandler(
                context: context,
                requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_Example_GetSliderValueRequest>(),
                responseSerializer: ProtobufSerializer<Pbkit_Wrp_Example_GetSliderValueResponse>(),
                userFunction: self.getSliderValue(request:context:)
            )

        default:
            return nil
        }
    }
}
