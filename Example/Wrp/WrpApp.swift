import Logging
import SwiftUI
import Wrp

@main
struct WrpApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                WrpAppView(url: "http://localhost:8000/wrp-example")
                    .tabItem {
                        Text("Bidirectional")
                    }
                WrpServerAppView(url: "http://localhost:8000/wrp-example-guest")
                    .tabItem {
                        Text("Server")
                    }
                WrpClientAppView(url: "http://localhost:8000/wrp-example-host")
                    .tabItem {
                        Text("Client")
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

    @State var wrpExampleClient: Pbkit_Wrp_Example_WrpExampleServiceClient!

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
                HStack {
                    Button("GetTextValue", action: {
                        if let response = try? wrpExampleClient.getTextValue(.init()) {
                            Task {
                                for try await res in response.response {
                                    print("adsfsdafasdfd")
                                    textValue = res.text
                                }
                            }
                        }
                    })
                    Button("GetSliderValue", action: {
                        if let response = try? wrpExampleClient.getSliderValue(.init()) {
                            Task {
                                for try await res in response.response {
                                    sliderValue = Double(res.value)
                                }
                            }
                        }
                    })
                }
            }.padding()
            WrpView(
                urlString: self.url,
                glue: glue
            ).onAppear {
                initNumber += 1
            }.onChange(of: initNumber) { _ in
                Task {
                    await withTaskGroup(of: Void.self) { taskGroup in
                        taskGroup.addTask {
                            print("Client")
                            var logger = Logger(label: "io.wrp.client")
                            logger.logLevel = .debug
                            let client = WrpClient.create(glue: glue, logger: logger)
                            self.wrpExampleClient = Pbkit_Wrp_Example_WrpExampleServiceClient(client: client)
                            try? await client.start()
                        }
                        taskGroup.addTask {
                            print("Server")
                            let provider = WrpExampleServiceProvider(textValue: $textValue, sliderValueStream: sliderValueStream.stream)
                            var logger = Logger(label: "io.wrp.server")
                            logger.logLevel = .debug
                            let server = WrpServer.create(glue: glue, serviceProviders: [provider], logger: logger)
                            do {
                                try await server.start()
                                initNumber += 1
                            } catch {
                                print("WrpView(Error): \(error)")
                            }
                        }
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

struct WrpClientAppView: View {
    let url: String
    let glue: WrpGlue = .init()
    @State var initNumber = 0
    @State var textValue = ""
    @State var sliderValue = 0.0

    @State var wrpExampleClient: Pbkit_Wrp_Example_WrpExampleServiceClient!

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
                HStack {
                    Button("GetTextValue", action: {
                        if let response = try? wrpExampleClient.getTextValue(.init()) {
                            Task {
                                for try await res in response.response {
                                    textValue = res.text
                                }
                            }
                        }
                    })
                    Button("GetSliderValue", action: {
                        if let response = try? wrpExampleClient.getSliderValue(.init()) {
                            Task {
                                for try await res in response.response {
                                    sliderValue = Double(res.value)
                                }
                            }
                        }
                    })
                }
            }.padding()
            WrpView(
                urlString: self.url,
                glue: glue
            ).onAppear {
                initNumber += 1
            }.onChange(of: initNumber) { _ in
                Task {
                    var logger = Logger(label: "io.wrp")
                    logger.logLevel = .debug
                    let client = WrpClient.create(glue: glue, logger: logger)
                    self.wrpExampleClient = Pbkit_Wrp_Example_WrpExampleServiceClient(client: client)
                    try? await client.start()
                }
            }
        }
    }
}

struct WrpServerAppView: View {
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
