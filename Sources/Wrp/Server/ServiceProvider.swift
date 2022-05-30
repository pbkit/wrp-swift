public protocol WrpServiceProvider: AnyObject {
    var serviceName: Substring { get }

    var methodNames: [Substring] { get }

    func handle(method: Substring, context: WrpRequestHandlerContext) -> WrpRequestHandlerProtocol?
}
