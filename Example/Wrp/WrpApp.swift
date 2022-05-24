import Logging
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
    @State var sliderValueStream: DeferStream<Double> = .init()
    let glue: WrpGlue = .init()
    @State var initNumber = 0
    @State var textValue = ""
    @State var sliderValue = 0.0

    init(url: String) {
        self.url = url
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                Text("Initialize \(initNumber) times")
                TextField("Text", text: $textValue)
                Slider(value: $sliderValue, in: 0 ... 100)
                Text("\(sliderValue)")
            }.padding()
            WrpView(
                urlString: self.url,
                glue: glue
            ).onAppear {
                initNumber += 1
            }.onChange(of: initNumber) { _ in
                Task {
                    let provider = WrpExampleServiceProvider(textValue: $textValue, sliderValueStream: sliderValueStream.stream)
                    let logger = Logger(label: "io.wrp")
                    let server = WrpServer.create(glue: glue, serviceProviders: [provider], logger: logger)
                    do {
                        try await server.start()
                        initNumber += 1
                    } catch {
                        print("WrpView(Error): \(error)")
                    }
                }
            }.onChange(of: sliderValue) { value in
                sliderValueStream.continuation?.yield(value)
            }.onChange(of: initNumber) { _ in
                sliderValueStream = .init()
            }
        }
    }
}
