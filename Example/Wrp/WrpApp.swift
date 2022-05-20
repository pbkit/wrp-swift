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
    @State var glue: WrpGlue = WrpGlue()
    @State var initNumber = 0
    
    init(url: String) {
        self.url = url
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(initNumber)")
            WrpView(
                urlString: self.url,
                glue: glue
            ).task(id: initNumber) {
                let server = WrpServer.create(glue: glue, configuration: .init(serviceProviders: [WrpTestServiceProvider()]))
                do {
                    try await server.start()
                    initNumber += 1
                } catch {
                    print("WrpView(Error): \(error)")
                }
            }
        }
    }
}
