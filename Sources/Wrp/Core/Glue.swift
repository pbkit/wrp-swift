import Foundation
import Logging
import WebKit

public class WrpGlue {
    public var webView: WKWebView?
    private var initialized: Bool = false
    private var queue: DeferStream<Data> = .init()
    private var sharedSequence: SharedAsyncSequence<AsyncStream<Data>>
    private let configuration: Configuration

    public init(
        configuration: Configuration = .init()
    ) {
        self.configuration = configuration
        self.sharedSequence = self.queue.stream.shared()
    }

    public func recv(_ data: Data) {
        self.configuration.logger.debug("recv: Received data \(data.map { $0 })")
        self.queue.continuation.yield(data)
    }

    public func read() -> AsyncStream<Data> {
        return .init { [self] in
            var iterator = sharedSequence.makeAsyncIterator()
            return try? await iterator.next()
        }
    }

    public func tryReconnect(afterReconnect: (() -> Void)?) {
        guard self.initialized == true else {
            self.initialized = true
            return
        }
        self.queue.continuation.finish()
        self.configuration.logger.debug("Closed")
        self.queue = .init()
        self.sharedSequence = self.queue.stream.shared()
        afterReconnect?()
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
