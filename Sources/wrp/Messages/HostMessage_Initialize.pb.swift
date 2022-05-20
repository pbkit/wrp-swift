import SwiftProtobuf
import Foundation

fileprivate let _protobuf_package = "pbkit.wrp"
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Pbkit_Wrp_WrpHostMessage_Initialize {
  public var availableMethods: [String] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpHostMessage_Initialize: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpHostMessage_Initialize: SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WrpHostMessage_Initialize"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "available_methods"),
  ]
}

extension Pbkit_Wrp_WrpHostMessage_Initialize: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.availableMethods) }()
      default: break
      }
    }
  }
}

extension Pbkit_Wrp_WrpHostMessage_Initialize {
  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.availableMethods.isEmpty {
      try visitor.visitRepeatedStringField(value: self.availableMethods, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }
}

extension Pbkit_Wrp_WrpHostMessage_Initialize {
  public static func == (lhs: Pbkit_Wrp_WrpHostMessage_Initialize, rhs: Pbkit_Wrp_WrpHostMessage_Initialize) -> Bool {
    if lhs.availableMethods != rhs.availableMethods { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
