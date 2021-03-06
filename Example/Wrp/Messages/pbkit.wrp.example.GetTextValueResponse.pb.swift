import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp.example"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_Example_GetTextValueResponse {
    public var text: String = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_Example_GetTextValueResponse: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_Example_GetTextValueResponse: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".GetTextValueResponse"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "text"),
    ]
}

extension Pbkit_Wrp_Example_GetTextValueResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeSingularStringField(value: &self.text)
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_Example_GetTextValueResponse {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.text != String() {
            try visitor.visitSingularStringField(value: self.text, fieldNumber: 1)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_Example_GetTextValueResponse {
    static func == (lhs: Pbkit_Wrp_Example_GetTextValueResponse, rhs: Pbkit_Wrp_Example_GetTextValueResponse) -> Bool {
        if lhs.text != rhs.text { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
