import SwiftProtobuf
import Foundation

fileprivate let _protobuf_package = "pbkit.wrp"
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Pbkit_Wrp_WrpUnaryRequest {
  public var payload: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpUnaryRequest: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpUnaryRequest: SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WrpUnaryRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "payload"),
  ]
}

extension Pbkit_Wrp_WrpUnaryRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.payload) }()
      default: break
      }
    }
  }
}

extension Pbkit_Wrp_WrpUnaryRequest {
  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.payload != String() {
      try visitor.visitSingularStringField(value: self.payload, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

extension Pbkit_Wrp_WrpUnaryRequest {
  public static func == (lhs: Pbkit_Wrp_WrpUnaryRequest, rhs: Pbkit_Wrp_WrpUnaryRequest) -> Bool {
    if lhs.payload != rhs.payload { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
