import SwiftProtobuf
import Foundation

fileprivate let _protobuf_package = "pbkit.wrp"
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Pbkit_Wrp_WrpGuestMessage_ReqPayload {
  public var reqID: String = String()

  public var payload: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpGuestMessage_ReqPayload: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpGuestMessage_ReqPayload: SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WrpGuestMessage_ReqPayload"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "req_id"),
    2: .same(proto: "payload"),
  ]
}

extension Pbkit_Wrp_WrpGuestMessage_ReqPayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.reqID) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.payload) }()
      default: break
      }
    }
  }
}

extension Pbkit_Wrp_WrpGuestMessage_ReqPayload {
  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.reqID != String() {
      try visitor.visitSingularStringField(value: self.reqID, fieldNumber: 1)
    }
    if self.payload != Data() {
      try visitor.visitSingularBytesField(value: self.payload, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

extension Pbkit_Wrp_WrpGuestMessage_ReqPayload {
  public static func == (lhs: Pbkit_Wrp_WrpGuestMessage_ReqPayload, rhs: Pbkit_Wrp_WrpGuestMessage_ReqPayload) -> Bool {
    if lhs.reqID != rhs.reqID { return false }
    if lhs.payload != rhs.payload { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
