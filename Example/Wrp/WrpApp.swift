import SwiftUI
import Wrp

@main
struct WrpApp: App {
    var body: some Scene {
        WindowGroup {
            if let url = URL(string: "http://localhost:3000") {
                VStack {
                    WrpWebView(url: url)
                }
            }
        }
    }
}

struct WrpWebView: View {
    let url: URL
    let channel: WrpChannel
    let server: WrpServer
    
    init(url: URL) {
        self.url = url
        self.server = .create(configuration: .init(serviceProviders: [WrpTestServiceProvider()]))
        self.channel = self.server.host.channel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WrpAppBridgeView(
                urlString: "http://localhost:3000",
                channel: self.channel
            ).task {
                await server.start()
            }
            List {
                Button("Initialize Host (Manual)", action: {
                    channel.send(message: .with {
                        $0.message = .hostInitialize(.with {
                            $0.availableMethods = ["pbkit.wrp.WrpTestService/Unary"]
                        })
                    })
                    print("HostInitialize sent!")
                })
            }.frame(height: 120)
        }
    }
}
