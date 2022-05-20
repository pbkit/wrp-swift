import WebKit
import Foundation

public class WrpGlue {
    public var webView: WKWebView?
    private var queue: DeferStream<Data> = .init()
    
    public init() { }

    public func recv(_ data: Data) {
        print("WrpGlue(recv): Received data")
        queue.continuation?.yield(data)
    }
    
    public func read() -> AsyncStream<Data> {
        return self.queue.stream
    }
    
    public func close() {
        self.queue.continuation?.finish()
        self.queue = .init()
    }
    
    public func registerWebView(_ webView: WKWebView) {
        self.webView = webView
    }
}
