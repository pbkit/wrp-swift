import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_WrpGuestMessage_ReqFinish {
    public var reqID: String = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpGuestMessage_ReqFinish: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpGuestMessage_ReqFinish: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".WrpGuestMessage_ReqFinish"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "req_id"),
    ]
}

extension Pbkit_Wrp_WrpGuestMessage_ReqFinish: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try try decoder.decodeSingularStringField(value: &self.reqID)
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_WrpGuestMessage_ReqFinish {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.reqID != String() {
            try visitor.visitSingularStringField(value: self.reqID, fieldNumber: 1)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_WrpGuestMessage_ReqFinish {
    static func == (lhs: Pbkit_Wrp_WrpGuestMessage_ReqFinish, rhs: Pbkit_Wrp_WrpGuestMessage_ReqFinish) -> Bool {
        if lhs.reqID != rhs.reqID { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
