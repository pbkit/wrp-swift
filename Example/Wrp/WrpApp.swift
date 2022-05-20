import SwiftUI
import Wrp

@main
struct WrpApp: App {
    var body: some Scene {
        WindowGroup {
            if let url = "http://localhost:8000/wrp-example-guest" {
                VStack {
                    WrpAppView(url: url)
                }
            }
        }
    }
}

struct WrpAppView: View {
    let url: String
    @State var server: WrpServer = .create(
        configuration: .init(serviceProviders: [WrpTestServiceProvider()])
    )
    
    init(url: String) {
        self.url = url
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WrpView(
                urlString: self.url,
                channel: server.host.channel
            ).task {
                await server.start()
            }
        }
    }
}
