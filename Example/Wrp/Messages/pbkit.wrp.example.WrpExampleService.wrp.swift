import GRPC
import SwiftProtobuf
import Wrp

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
