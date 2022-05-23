import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_WrpHostMessage_ResStart {
    public var reqID: String = .init()

    public var header: [String: String] = [:]

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpHostMessage_ResStart: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpHostMessage_ResStart: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".WrpHostMessage_ResStart"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "req_id"),
        2: .same(proto: "header"),
    ]
}

extension Pbkit_Wrp_WrpHostMessage_ResStart: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try try decoder.decodeSingularStringField(value: &self.reqID)
            case 2: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString, SwiftProtobuf.ProtobufString>.self, value: &self.header) }()
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_WrpHostMessage_ResStart {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.reqID != String() {
            try visitor.visitSingularStringField(value: self.reqID, fieldNumber: 1)
        }
        if !self.header.isEmpty {
            try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString, SwiftProtobuf.ProtobufString>.self, value: self.header, fieldNumber: 2)
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_WrpHostMessage_ResStart {
    static func == (lhs: Pbkit_Wrp_WrpHostMessage_ResStart, rhs: Pbkit_Wrp_WrpHostMessage_ResStart) -> Bool {
        if lhs.reqID != rhs.reqID { return false }
        if lhs.header != rhs.header { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
