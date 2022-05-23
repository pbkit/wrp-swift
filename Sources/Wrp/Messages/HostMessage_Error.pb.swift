import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_WrpHostMessage_Error {
    public var message: String = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpHostMessage_Error: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpHostMessage_Error: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".WrpHostMessage_Error"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "message"),
    ]
}

extension Pbkit_Wrp_WrpHostMessage_Error: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try try decoder.decodeSingularStringField(value: &self.message)
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_WrpHostMessage_Error {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.message != String() {
            try visitor.visitSingularStringField(value: self.message, fieldNumber: 1)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_WrpHostMessage_Error {
    static func == (lhs: Pbkit_Wrp_WrpHostMessage_Error, rhs: Pbkit_Wrp_WrpHostMessage_Error) -> Bool {
        if lhs.message != rhs.message { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
