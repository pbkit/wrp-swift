import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp.example"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_Example_GetSliderValueResponse {
    public var value: Int32 = 0

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_Example_GetSliderValueResponse: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_Example_GetSliderValueResponse: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".GetSliderValueResponse"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "value"),
    ]
}

extension Pbkit_Wrp_Example_GetSliderValueResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try try decoder.decodeSingularInt32Field(value: &self.value)
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_Example_GetSliderValueResponse {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.value != 0 {
            try visitor.visitSingularInt32Field(value: self.value, fieldNumber: 1)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_Example_GetSliderValueResponse {
    static func == (lhs: Pbkit_Wrp_Example_GetSliderValueResponse, rhs: Pbkit_Wrp_Example_GetSliderValueResponse) -> Bool {
        if lhs.value != rhs.value { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
