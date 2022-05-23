import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_WrpGuestMessage_ReqStart {
    public var reqID: String = .init()

    public var methodName: String = .init()

    public var metadata: [String: String] = [:]

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpGuestMessage_ReqStart: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpGuestMessage_ReqStart: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".WrpGuestMessage_ReqStart"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "req_id"),
        2: .same(proto: "method_name"),
        3: .same(proto: "metadata"),
    ]
}

extension Pbkit_Wrp_WrpGuestMessage_ReqStart: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeSingularStringField(value: &self.reqID)
            case 2: try decoder.decodeSingularStringField(value: &self.methodName)
            case 3: try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString, SwiftProtobuf.ProtobufString>.self, value: &self.metadata)
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_WrpGuestMessage_ReqStart {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.reqID != String() {
            try visitor.visitSingularStringField(value: self.reqID, fieldNumber: 1)
        }
        if self.methodName != String() {
            try visitor.visitSingularStringField(value: self.methodName, fieldNumber: 2)
        }
        if !self.metadata.isEmpty {
            try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString, SwiftProtobuf.ProtobufString>.self, value: self.metadata, fieldNumber: 3)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_WrpGuestMessage_ReqStart {
    static func == (lhs: Pbkit_Wrp_WrpGuestMessage_ReqStart, rhs: Pbkit_Wrp_WrpGuestMessage_ReqStart) -> Bool {
        if lhs.reqID != rhs.reqID { return false }
        if lhs.methodName != rhs.methodName { return false }
        if lhs.metadata != rhs.metadata { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
