import Foundation
import WebKit

public class WrpSocket {
    public let glue: WrpGlue
    private var status: Status = .uninitialized
    private var webView: WKWebView?
    
    init(glue: WrpGlue) {
        self.glue = glue
    }
    
    public func registerWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    public func handshake(interval: UInt32 = 500, limit: Int = 10) async {
        for _ in 0..<interval {
            guard let webView = self.webView else {
                print("WrpSocket(handshake): No WebView")
                continue;
            }
            do {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(), Error>) in
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
                print("WrpSocket(handshake): Handshake complete!")
                return
            } catch {
                print("WrpSocket(handshake): Retrying...")
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000))
            }
        }
    }
    
    @discardableResult
    public func read() -> AsyncStream<Data> {
        self.glue.read()
    }
    
    public func write(_ data: Data) {
         DispatchQueue.main.async {
             Task.init {
                 assert(Thread.isMainThread, "WKWebView.evaluateJavaScript(_:completionHandler:) must be used from main thread only")
                 
                 guard let webView = self.webView else { return }
                 
                 let payload = data.toWrpPayloadString()
                 print("WrpSocket(write)(\(data.count)): window['<glue>'].recv(`\(payload.map { $0 })`)")
                     
                 do {
                     try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(), Error>) in
                         DispatchQueue.main.async {
                             webView.evaluateJavaScript("void globalThis['<glue>'].recv(`\(payload)`)") { _, error in
                                 if let error = error {
                                     continuation.resume(throwing: error)
                                 } else {
                                     continuation.resume()
                                 }
                             }
                         }
                     }
                     print("WrpSocket(write): Sent Successfully!")
                 } catch {
                     print(error)
                 }
             }
         }
    }
    
    public enum SocketError: Error {
        case javascriptError(Error)
        case uninitialized
    }
    
    public enum Status {
        case initialized
        case uninitialized
    }
}
