import Foundation
import Logging
import WebKit

public class WrpGlue {
    public var webView: WKWebView?
    private var queue: DeferStream<Data> = .init()
    private let configuration: Configuration

    public init(
        configuration: Configuration = .init()
    ) {
        self.configuration = configuration
    }

    public func recv(_ data: Data) {
        self.configuration.logger.debug("recv: Received data \(data.map { $0 })")
        self.queue.continuation.yield(data)
    }

    public func read() -> AsyncStream<Data> {
        return self.queue.stream
    }

    public func close() {
        self.queue.continuation.finish()
        self.configuration.logger.debug("Closed")
        self.queue = .init()
    }

    public func registerWebView(_ webView: WKWebView) {
        self.webView = webView
    }
}

public extension WrpGlue {
    struct Configuration {
        public var logger: Logger
        public init(
            logger: Logger = .init(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        ) {
            self.logger = logger
            self.logger[metadataKey: "stage"] = "glue"
        }
    }
}
