import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_WrpHostMessage_ResPayload {
    public var reqID: String = .init()

    public var payload: Data = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpHostMessage_ResPayload: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpHostMessage_ResPayload: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".WrpHostMessage_ResPayload"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "req_id"),
        2: .same(proto: "payload"),
    ]
}

extension Pbkit_Wrp_WrpHostMessage_ResPayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try try decoder.decodeSingularStringField(value: &self.reqID)
            case 2: try try decoder.decodeSingularBytesField(value: &self.payload)
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_WrpHostMessage_ResPayload {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.reqID != String() {
            try visitor.visitSingularStringField(value: self.reqID, fieldNumber: 1)
        }
        if self.payload != Data() {
            try visitor.visitSingularBytesField(value: self.payload, fieldNumber: 2)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_WrpHostMessage_ResPayload {
    static func == (lhs: Pbkit_Wrp_WrpHostMessage_ResPayload, rhs: Pbkit_Wrp_WrpHostMessage_ResPayload) -> Bool {
        if lhs.reqID != rhs.reqID { return false }
        if lhs.payload != rhs.payload { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
