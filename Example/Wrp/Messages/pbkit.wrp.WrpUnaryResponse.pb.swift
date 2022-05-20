import SwiftProtobuf
import Foundation

fileprivate let _protobuf_package = "pbkit.wrp"
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Pbkit_Wrp_WrpUnaryResponse {
  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpUnaryResponse: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpUnaryResponse: SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WrpUnaryResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [:]
}

extension Pbkit_Wrp_WrpUnaryResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      default: break
      }
    }
  }
}

extension Pbkit_Wrp_WrpUnaryResponse {
  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }
}

extension Pbkit_Wrp_WrpUnaryResponse {
  public static func == (lhs: Pbkit_Wrp_WrpUnaryResponse, rhs: Pbkit_Wrp_WrpUnaryResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
