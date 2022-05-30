import Logging
import SwiftUI
import Wrp

@main
struct WrpApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                WrpAppView(url: "https://wrp-example.deno.dev/wrp-example")
                    .tabItem {
                        Text("Bidirectional")
                    }.background(Color.gray.opacity(0.1).ignoresSafeArea())
                WrpServerAppView(url: "https://wrp-example.deno.dev/wrp-example-guest")
                    .tabItem {
                        Text("Server")
                    }.background(Color.gray.opacity(0.1).ignoresSafeArea())
                WrpClientAppView(url: "https://wrp-example.deno.dev/wrp-example-host")
                    .tabItem {
                        Text("Client")
                    }.background(Color.gray.opacity(0.1).ignoresSafeArea())
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

    @State var responseTextValue = ""
    @State var responseSliderValue = 0

    @State var wrpExampleClient: Pbkit_Wrp_Example_WrpExampleServiceWrpClient!

    init(url: String) {
        self.url = url
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Bidirectional (both server/client)").fontWeight(.semibold)
            VStack(alignment: .center, spacing: 0) {
                Text("Initialize \(initNumber) times")
                VStack {
                    Divider()
                    Text("Server Inputs").fontWeight(.semibold)
                    HStack {
                        Text("Text")
                        TextField("TextValue", text: $textValue)
                    }
                    HStack {
                        Text("Slider")
                        Slider(value: $sliderValue, in: 0 ... 100)
                    }
                    Divider()
                }.padding(.top)
                VStack {
                    Text("Server Response").fontWeight(.semibold)
                    VStack(alignment: .leading) {
                        Text("TextValue: \(responseTextValue)")
                        HStack {
                            Spacer()
                        }
                        Text("SliderValue: \(responseSliderValue)")
                    }
                    HStack {
                        Button("GetTextValue", action: {
                            if let response = try? wrpExampleClient.getTextValue(.init()) {
                                Task {
                                    for try await res in response.response {
                                        responseTextValue = res.text
                                    }
                                }
                            }
                        }).buttonStyle(
                            WrpButtonStyle(color: Color.blue.opacity(0.7))
                        )
                        Button("GetSliderValue", action: {
                            if let response = try? wrpExampleClient.getSliderValue(.init()) {
                                Task {
                                    for try await res in response.response {
                                        responseSliderValue = Int(res.value)
                                    }
                                }
                            }
                        }).buttonStyle(
                            WrpButtonStyle(color: Color.orange.opacity(0.7))
                        )
                    }
                }.padding([.top])
            }.padding()
            Divider()
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
                            self.wrpExampleClient = Pbkit_Wrp_Example_WrpExampleServiceWrpClient(client: client)
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

#if DEBUG
struct WrpAppViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            WrpAppView(url: "http://localhost:8000/wrp-example")
        }
    }
}
#endif

struct WrpClientAppView: View {
    let url: String
    let glue: WrpGlue = .init()
    @State var initNumber = 0

    @State var responseTextValue = ""
    @State var responseSliderValue = 0

    @State var wrpExampleClient: Pbkit_Wrp_Example_WrpExampleServiceWrpClient!

    init(url: String) {
        self.url = url
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Client (<-> WebView Server)").fontWeight(.semibold)
            VStack(alignment: .center, spacing: 0) {
                Text("Initialize \(initNumber) times")
                VStack {
                    Divider()
                    Text("Server Response").fontWeight(.semibold)
                    VStack(alignment: .leading) {
                        Text("TextValue: \(responseTextValue)")
                        HStack {
                            Spacer()
                        }
                        Text("SliderValue: \(responseSliderValue)")
                    }
                    HStack {
                        Button("GetTextValue", action: {
                            if let response = try? wrpExampleClient.getTextValue(.init()) {
                                Task {
                                    for try await res in response.response {
                                        responseTextValue = res.text
                                    }
                                }
                            }
                        }).buttonStyle(
                            WrpButtonStyle(color: Color.blue.opacity(0.7))
                        )
                        Button("GetSliderValue", action: {
                            if let response = try? wrpExampleClient.getSliderValue(.init()) {
                                Task {
                                    for try await res in response.response {
                                        responseSliderValue = Int(res.value)
                                    }
                                }
                            }
                        }).buttonStyle(
                            WrpButtonStyle(color: Color.orange.opacity(0.7))
                        )
                    }
                }.padding([.top])
            }.padding()
            Divider()
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
                    self.wrpExampleClient = Pbkit_Wrp_Example_WrpExampleServiceWrpClient(client: client)
                    try? await client.start()
                }
            }
        }
    }
}

#if DEBUG
struct WrpClientAppViewPreview: PreviewProvider {
    static var previews: some View {
        WrpClientAppView(url: "http://localhost:8000/wrp-example-host")
    }
}
#endif

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
        VStack(alignment: .center, spacing: 0) {
            Text("Server (<-> WebView Client)").fontWeight(.semibold)
            VStack(alignment: .center, spacing: 0) {
                Text("Initialize \(initNumber) times")
                VStack {
                    Divider()
                    Text("Server Inputs").fontWeight(.semibold)
                    HStack {
                        Text("Text")
                        TextField("TextValue", text: $textValue)
                    }
                    HStack {
                        Text("Slider")
                        Slider(value: $sliderValue, in: 0 ... 100)
                    }
                }.padding(.top)
            }.padding()
            Divider()
            WrpView(
                urlString: self.url,
                glue: glue
            ).onAppear {
                initNumber += 1
            }.onChange(of: initNumber) { _ in
                Task {
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
            }.onChange(of: sliderValue) { value in
                sliderValueStream.continuation?.yield(value)
            }.onChange(of: initNumber) { _ in
                sliderValueStream = .init()
            }
        }
    }
}

#if DEBUG
struct WrpServerAppViewPreview: PreviewProvider {
    static var previews: some View {
        WrpServerAppView(url: "http://localhost:8000/wrp-example-guest")
    }
}
#endif
