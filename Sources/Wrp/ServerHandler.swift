import Foundation
import Logging
import GRPC
import SwiftProtobuf

public protocol WrpHandlerProvider: AnyObject {
    var serviceName: Substring { get }
    
    var methodNames: [Substring] { get }
    
    func handle(methodName: Substring, context: WrpRequestContext) -> WrpServerHandlerProtocol?
}

public protocol WrpServerHandlerProtocol {
  func call() -> WrpServerHandlerResult
}

public struct WrpServerHandlerResult {
  let header: AsyncStream<[String:String]>
  let trailer: AsyncStream<[String:String]>
  let payload: AsyncStream<Data>
}


public struct WrpRequestContext {
    let methodName: WrpRequestMethodIdentifier
    let metadata: [String:String]
    let request: AsyncStream<Data>
    let sendHeader: (_ header: [String:String]) -> ()
    let sendPayload: (_ payload: Data) -> ()
    let sendTrailer: (_ trailer: inout [String:String]) -> ()
}

public class WrpRequestMethodIdentifier {
  let serviceName: Substring
  let methodName: Substring
  
  init(identifier: String) throws {
    let splitted = identifier.split(separator: "/")
    guard let serviceName = splitted.first,
          let methodName = splitted.last else {
      throw SplitError.invalidInput(identifier)
    }
    self.serviceName = serviceName
    self.methodName = methodName
  }
  
  enum SplitError: Error {
    case invalidInput(String)
  }
}

public struct MethodHandlerContext<Response: SwiftProtobuf.Message> {
  public let sendHeader: (_ header: [String:String]) -> ()
  public let sendMessage: (_ message: Response) -> ()
  public let sendTrailer: (_ trailer: inout [String:String]) -> ()
}

public class WrpServerHandler<
  Request: SwiftProtobuf.Message,
  Response: SwiftProtobuf.Message
>: WrpServerHandlerProtocol{
  public typealias Serializer = ProtobufSerializer<Response>
  public typealias Deserializer = ProtobufDeserializer<Request>
  
  @usableFromInline
  internal let serializer: Serializer
  
  @usableFromInline
  internal let deserializer: Deserializer
  
  @usableFromInline
  internal let context: WrpRequestContext
  
  @usableFromInline
  internal let userFunction: (AsyncStream<Request>, MethodHandlerContext<Response>) -> ()
  
  @inlinable
  public init(
    context: WrpRequestContext,
    responseSerializer: Serializer,
    requestDeserializer: Deserializer,
    userFunction: @escaping (AsyncStream<Request>,  MethodHandlerContext<Response>) -> ()
  ) {
    self.context = context
    self.serializer = responseSerializer
    self.deserializer = requestDeserializer
    self.userFunction = userFunction
  }
  
  public func call() -> WrpServerHandlerResult {
    let requestStream = AsyncStream<Request> { continuation in
      Task.init {
        for await data in context.request {
          if let request = try? Request.init(contiguousBytes: data) {
            continuation.yield(request)
          }
        }
        continuation.finish()
      }
    }
    let header = DeferStream<[String:String]>()
    let trailer = DeferStream<[String:String]>()
    let payload = DeferStream<Data>()
    
    self.userFunction(
      requestStream,
      .init(
        sendHeader: {
          header.continuation?.yield($0)
          header.continuation?.finish()
        },
        sendMessage: { message in
          if let data = try? message.serializedData() {
            payload.continuation?.yield(data)
          }
        },
        sendTrailer: {
          payload.continuation?.finish()
          trailer.continuation?.yield($0)
          trailer.continuation?.finish()
        }
      )
    )
    
    return .init(
      header: header.stream,
      trailer: trailer.stream,
      payload: payload.stream
    )
  }
}
