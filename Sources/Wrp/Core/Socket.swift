import Foundation
import Logging
import WebKit

public class WrpSocket {
    public let glue: WrpGlue
    private var configuration: Configuration
    private var status: Status = .uninitialized

    init(glue: WrpGlue, configuration: Configuration = .init()) {
        self.glue = glue
        self.configuration = configuration
    }

    public func handshake(interval: UInt32 = 500, limit: Int = 10) async throws {
        for count in 0 ..< interval {
            guard let webView = self.glue.webView else {
                self.configuration.logger.debug("handshake: Cannot find WebView")
                throw SocketError.webViewError("Cannot find Webview")
            }
            do {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    DispatchQueue.main.async {
                        // Trick for avoiding unexpected exception on valid result
                        webView.evaluateJavaScript("globalThis['<glue>'].toString()") { _, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume(returning: ())
                            }
                        }
                    }
                }
                self.status = .initialized
                self.configuration.logger.debug("handshake: Completed")
                return
            } catch {
                self.configuration.logger.debug("handshake: Retrying \(count)/\(interval)")
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000))
            }
        }
    }

    @discardableResult
    public func read() -> AsyncStream<Data> {
        AsyncStream { continuation in
            guard status != .closed else {
                continuation.finish()
                return
            }
            Task.init {
                for await data in self.glue.read() {
                    continuation.yield(data)
                }
                continuation.finish()
            }
        }
    }

    public func write(_ data: Data) {
        DispatchQueue.main.async {
            Task.init {
                assert(Thread.isMainThread, "WKWebView.evaluateJavaScript(_:completionHandler:) must be used from main thread only")
                guard let webView = self.glue.webView else { return }
                let payload = data.encode()
                self.configuration.logger.debug("write(\(data.count), \(payload.count)): <glue>.recv(\(payload))")
                do {
                    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                        DispatchQueue.main.async {
                            webView.evaluateJavaScript("void globalThis['<glue>'].recv(\(payload))") { _, error in
                                if let error = error {
                                    continuation.resume(throwing: error)
                                } else {
                                    continuation.resume()
                                }
                            }
                        }
                    }
                    self.configuration.logger.debug("write: Sent successfully")
                } catch {
                    self.configuration.logger.error("write: Error on evaluateJavascript \(error)")
                }
            }
        }
    }
}

public extension WrpSocket {
    struct Configuration {
        public var logger: Logger
        public init(
            logger: Logger = .init(label: "io.wrp", factory: { _ in SwiftLogNoOpLogHandler() })
        ) {
            self.logger = logger
            self.logger[metadataKey: "stage"] = "socket"
        }
    }
}

public extension WrpSocket {
    enum SocketError: Error {
        case javascriptError(Error)
        case webViewError(String)
        case uninitialized
    }

    enum Status {
        case initialized
        case uninitialized
        case closed
    }
}
