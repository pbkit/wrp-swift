import GRPC
import NIO
import SwiftProtobuf

internal protocol Pbkit_Wrp_WrpTestServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Pbkit_Wrp_WrpTestServiceClientInterceptorFactoryProtocol? { get }

  func unary(
    _ request: Pbkit_Wrp_WrpUnaryRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>

  func aBC(
    callOptions: CallOptions?
  ) -> ClientStreamingCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>

  func aBC_DEF(
    _ request: Pbkit_Wrp_WrpUnaryRequest,
    callOptions: CallOptions?,
    handler: @escaping (Pbkit_Wrp_WrpUnaryResponse) -> Void
  ) -> ServerStreamingCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>

  func aBC_DEF_G(
    callOptions: CallOptions?,
    handler: @escaping (Pbkit_Wrp_WrpUnaryResponse) -> Void
  ) -> BidirectionalStreamingCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>
}

extension Pbkit_Wrp_WrpTestServiceClientProtocol {
  public var serviceName: String {
    return "pbkit.wrp.WrpTestService"
  }

  internal func unary(
    _ request: Pbkit_Wrp_WrpUnaryRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse> {
    return self.makeUnaryCall(
      path: "/pbkit.wrp.WrpTestService/Unary",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeUnaryInterceptors() ?? []
    )
  }

  internal func aBC(
    callOptions: CallOptions? = nil
  ) -> ClientStreamingCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse> {
    return self.makeClientStreamingCall(
      path: "/pbkit.wrp.WrpTestService/ABC",
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeABCInterceptors() ?? []
    )
  }

  internal func aBC_DEF(
    _ request: Pbkit_Wrp_WrpUnaryRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (Pbkit_Wrp_WrpUnaryResponse) -> Void
  ) -> ServerStreamingCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse> {
    return self.makeServerStreamingCall(
      path: "/pbkit.wrp.WrpTestService/ABC_DEF",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeABC_DEFInterceptors() ?? [],
      handler: handler
    )
  }

  internal func aBC_DEF_G(
    callOptions: CallOptions? = nil,
    handler: @escaping (Pbkit_Wrp_WrpUnaryResponse) -> Void
  ) -> BidirectionalStreamingCall<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse> {
    return self.makeBidirectionalStreamingCall(
      path: "/pbkit.wrp.WrpTestService/ABC_DEF_G",
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeABC_DEF_GInterceptors() ?? [],
      handler: handler
    )
  }
}

public protocol Pbkit_Wrp_WrpTestServiceClientInterceptorFactoryProtocol {
  func makeUnaryInterceptors() -> [ClientInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]

  func makeABCInterceptors() -> [ClientInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]

  func makeABC_DEFInterceptors() -> [ClientInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]

  func makeABC_DEF_GInterceptors() -> [ClientInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]
}

public final class Pbkit_Wrp_WrpTestServiceClient: Pbkit_Wrp_WrpTestServiceClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Pbkit_Wrp_WrpTestServiceClientInterceptorFactoryProtocol?

  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Pbkit_Wrp_WrpTestServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public protocol Pbkit_Wrp_WrpTestServiceProvider: CallHandlerProvider {
  var interceptors: Pbkit_Wrp_WrpTestServiceServerInterceptorFactoryProtocol? { get }

  func unary(request: Pbkit_Wrp_WrpUnaryRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Pbkit_Wrp_WrpUnaryResponse>

  func aBC(context: UnaryResponseCallContext<Pbkit_Wrp_WrpUnaryResponse>) -> EventLoopFuture<(StreamEvent<Pbkit_Wrp_WrpUnaryRequest>) -> Void>

  func aBC_DEF(request: Pbkit_Wrp_WrpUnaryRequest, context: StreamingResponseCallContext<Pbkit_Wrp_WrpUnaryResponse>) -> EventLoopFuture<GRPCStatus>

  func aBC_DEF_G(context: StreamingResponseCallContext<Pbkit_Wrp_WrpUnaryResponse>) -> EventLoopFuture<(StreamEvent<Pbkit_Wrp_WrpUnaryRequest>) -> Void>
}

extension Pbkit_Wrp_WrpTestServiceProvider {
  public var serviceName: Substring { return "pbkit.wrp.WrpTestService" }

  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Unary":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_WrpUnaryRequest>(),
        responseSerializer: ProtobufSerializer<Pbkit_Wrp_WrpUnaryResponse>(),
        interceptors: self.interceptors?.makeUnaryInterceptors() ?? [],
        userFunction: self.unary(request:context:)
      )

    case "ABC":
      return ClientStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_WrpUnaryRequest>(),
        responseSerializer: ProtobufSerializer<Pbkit_Wrp_WrpUnaryResponse>(),
        interceptors: self.interceptors?.makeABCInterceptors() ?? [],
        observerFactory: self.aBC(context:)
      )

    case "ABC_DEF":
      return ServerStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_WrpUnaryRequest>(),
        responseSerializer: ProtobufSerializer<Pbkit_Wrp_WrpUnaryResponse>(),
        interceptors: self.interceptors?.makeABC_DEFInterceptors() ?? [],
        userFunction: self.aBC_DEF(request:context:)
      )

    case "ABC_DEF_G":
      return BidirectionalStreamingServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Pbkit_Wrp_WrpUnaryRequest>(),
        responseSerializer: ProtobufSerializer<Pbkit_Wrp_WrpUnaryResponse>(),
        interceptors: self.interceptors?.makeABC_DEF_GInterceptors() ?? [],
        observerFactory: self.aBC_DEF_G(context:)
      )

    default:
      return nil
    }
  }
}

public protocol Pbkit_Wrp_WrpTestServiceServerInterceptorFactoryProtocol {
  func makeUnaryInterceptors() -> [ServerInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]

  func makeABCInterceptors() -> [ServerInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]

  func makeABC_DEFInterceptors() -> [ServerInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]

  func makeABC_DEF_GInterceptors() -> [ServerInterceptor<Pbkit_Wrp_WrpUnaryRequest, Pbkit_Wrp_WrpUnaryResponse>]
}
