import GRPC
import SwiftProtobuf
import Wrp

internal protocol Pbkit_Wrp_Example_WrpExampleServiceWrpClientProtocol {
    var client: WrpClient { get }

    func getTextValue(
        _ request: Pbkit_Wrp_Example_GetTextValueRequest,
        callOptions: WrpClientCallOptions?
    ) throws -> WrpUnaryResponse<Pbkit_Wrp_Example_GetTextValueResponse>

    func getSliderValue(_ request: Pbkit_Wrp_Example_GetSliderValueRequest, callOptions: WrpClientCallOptions?) throws -> WrpStreamingResponse<Pbkit_Wrp_Example_GetSliderValueResponse>
}

extension Pbkit_Wrp_Example_WrpExampleServiceWrpClientProtocol {
    func getTextValue(
        _ request: Pbkit_Wrp_Example_GetTextValueRequest,
        callOptions: WrpClientCallOptions? = nil
    ) throws -> WrpUnaryResponse<Pbkit_Wrp_Example_GetTextValueResponse> {
        return try self.client.makeUnaryCall(path: "pbkit.wrp.example.WrpExampleService/GetTextValue", request: request)
    }

    func getSliderValue(
        _ request: Pbkit_Wrp_Example_GetSliderValueRequest,
        callOptions: WrpClientCallOptions? = nil
    ) throws -> WrpStreamingResponse<Pbkit_Wrp_Example_GetSliderValueResponse> {
        return try self.client.makeServerStreamingCall(path: "pbkit.wrp.example.WrpExampleService/GetSliderValue", request: request)
    }
}

public final class Pbkit_Wrp_Example_WrpExampleServiceClient: Pbkit_Wrp_Example_WrpExampleServiceWrpClientProtocol {
    public let client: WrpClient

    public init(
        client: WrpClient
    ) {
        self.client = client
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
