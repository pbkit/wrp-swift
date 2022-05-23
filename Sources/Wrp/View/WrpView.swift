import SwiftUI
import WebKit

public struct WrpView: UIViewControllerRepresentable {
    let urlString: String
    let configuration: WKWebViewConfiguration
    let glue: WrpGlue

    public init(
        urlString: String,
        configuration: WKWebViewConfiguration = .init(),
        glue: WrpGlue
    ) {
        self.urlString = urlString
        self.configuration = configuration
        self.glue = glue
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        AppBridgeViewController(
            urlString: self.urlString,
            configuration: self.configuration,
            messageHandler: context.coordinator,
            glue: self.glue
        )
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public class Coordinator: NSObject, WKScriptMessageHandler {
        private let parent: WrpView

        init(_ parent: WrpView) {
            self.parent = parent
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let payload = message.body as? String else { return }
            let data = Data(payload.unicodeScalars.map { v in UInt8(v.value) })
            print("WrpWebView: Received message body: \(data.map { $0 })")
            self.parent.glue.recv(data)
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
    private let glue: WrpGlue

    var webview: WKWebView {
        return self._webview
    }

    private var appBridgeConfiguration: WKWebViewConfiguration {
        let controller = WKUserContentController()

        // @wrp: Inject glue to userContentController
        // WrpWeb can call this with `globalThis.webkit.messageHandlers.glue.postMessage`.
        controller.add(self.messageHandler, name: "glue")
        print("WrpWebView: MessageHandler added")

        let configuration = self.configuration
        configuration.userContentController = controller
        return configuration
    }

    init(
        urlString: String,
        configuration: WKWebViewConfiguration,
        messageHandler: WKScriptMessageHandler,
        glue: WrpGlue
    ) {
        self.urlString = urlString
        self.configuration = configuration
        self.messageHandler = messageHandler

        // @wrp: WrpGlue
        self.glue = glue

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.layout()
    }

    func addSubviews() {
        self._webview = WKWebView(frame: .zero, configuration: self.appBridgeConfiguration)
        self._webview.translatesAutoresizingMaskIntoConstraints = false
        self._webview.uiDelegate = self
        self._webview.navigationDelegate = self

        // @wrp: Inject webview on WrpGlue
        self.glue.registerWebView(self.webview)

        view.addSubview(self._webview)
    }

    func layout() {
        self._webview.pinEdges(to: self.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isBeingPresented || isMovingToParent, let urlString = urlString,
           let url = URL(string: urlString)
        {
            let request = URLRequest(url: url)
            self._webview.load(request)
        }
    }
}

extension AppBridgeViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish: WKNavigation) {
        self.glue.close()
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
                completionHandler()
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
                completionHandler(false)
            }
        )

        alertController.addAction(
            UIAlertAction(
                title: "Confirm",
                style: .default
            ) { _ in
                completionHandler(true)
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
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left),
        ])
    }

    func pinEdges(to other: UIView) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}
