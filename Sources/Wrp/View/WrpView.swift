import SwiftUI
import WebKit

public struct WrpView: UIViewControllerRepresentable {
    let urlString: String
    let configuration: WKWebViewConfiguration
    let channel: WrpChannel
    
    public init(
        urlString: String,
        configuration: WKWebViewConfiguration = .init(),
        channel: WrpChannel
    ) {
        self.urlString = urlString
        self.configuration = configuration
        
        // @wrp: WrpGlue
        self.channel = channel
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        AppBridgeViewController(
            urlString: self.urlString,
            configuration: self.configuration,
            messageHandler: context.coordinator,
            channel: self.channel
        )
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    public class Coordinator: NSObject, WKScriptMessageHandler {
        private let parent: WrpView
        
        init(_ parent: WrpView) {
            self.parent = parent
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let payload = message.body as? String else { return }
            let data = Data(payload.unicodeScalars.map {v in UInt8(v.value)})
            print("WrpWebView: Received message body: \(data.map { $0 })")
            try? self.parent.channel.socket.glue.recv(data)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class AppBridgeViewController: UIViewController {
    private var _webview: WKWebView!
    private let urlString: String?
    private let configuration: WKWebViewConfiguration
    private let messageHandler: WKScriptMessageHandler
    
    // @wrp: WrpGlue
    private let channel: WrpChannel
    
    var webview: WKWebView {
        return _webview
    }
    
    private var appBridgeConfiguration: WKWebViewConfiguration {
        let controller = WKUserContentController()
        
        // @wrp: Inject glue to userContentController
        // WrpWeb can call this with `globalThis.webkit.messageHandlers.glue.postMessage`.
        controller.add(messageHandler, name: "glue")
        print("WrpWebView: MessageHandler added")
        
        let configuration = self.configuration
        configuration.userContentController = controller
        return configuration
    }

    init(
        urlString: String,
        configuration: WKWebViewConfiguration,
        messageHandler: WKScriptMessageHandler,
        channel: WrpChannel
    ) {
        self.urlString = urlString
        self.configuration = configuration
        self.messageHandler = messageHandler
        
        // @wrp: WrpGlue
        self.channel = channel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        layout()
    }
    
    func addSubviews() {
        _webview = WKWebView(frame:.zero, configuration: appBridgeConfiguration)
        _webview.translatesAutoresizingMaskIntoConstraints = false
        _webview.uiDelegate = self
        _webview.navigationDelegate = self
        
        // @wrp: Inject webview on WrpGlue
        channel.socket.registerWebView(webview)
        
        view.addSubview(_webview)
    }
    
    func layout() {
      _webview.pinEdges(to: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      if isBeingPresented || isMovingToParent, let urlString = urlString,
         let url = URL(string: urlString)
      {
        let request = URLRequest(url: url)
        _webview.load(request)
      }
    }
}


extension AppBridgeViewController: WKUIDelegate, WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
  // @TODO: Check if we need to check with other types only (like submit)
  if decidePolicyFor.navigationType != .other {
      self.channel.socket.close()
  }
    decisionHandler(.allow)
  }
    
  func webView(
    _ webView: WKWebView,
    runJavaScriptAlertPanelWithMessage message: String,
    initiatedByFrame frame: WKFrameInfo,
    completionHandler: @escaping () -> Void
  ) {
    let alertController = UIAlertController(
      title: nil,
      message: message,
      preferredStyle: .alert
    )
    
    alertController.addAction(
      UIAlertAction(
        title: "Cancel",
        style: .cancel
      ) { _ in
        return completionHandler()
      }
    )
    
    DispatchQueue.main.async {
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func webView(
    _ webView: WKWebView,
    runJavaScriptConfirmPanelWithMessage message: String,
    initiatedByFrame frame: WKFrameInfo,
    completionHandler: @escaping (Bool) -> Void
  ) {
    let alertController = UIAlertController(
      title: nil,
      message: message,
      preferredStyle: .alert
    )
    
    alertController.addAction(
      UIAlertAction(
        title: "Cancel",
        style: .cancel
      ) { _ in
        return completionHandler(false)
      }
    )
    
    alertController.addAction(
      UIAlertAction(
        title: "Confirm",
        style: .default
      ) { _ in
        return completionHandler(true)
      }
    )
    
    DispatchQueue.main.async {
      self.present(alertController, animated: true, completion: nil)
    }
  }
}

extension UIView {
  func attachAnchors(to view: UIView, with insets: UIEdgeInsets = .zero) {
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      rightAnchor.constraint(equalTo: view.rightAnchor, constant: -insets.right),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
      leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left)
    ])
  }
  
  func pinEdges(to other: UIView) {
    leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
    trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
    topAnchor.constraint(equalTo: other.topAnchor).isActive = true
    bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
  }
}
