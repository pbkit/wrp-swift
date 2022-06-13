import Logging
import SwiftUI
import Wrp

@main
struct WrpApp: App {
    var body: some Scene {
        WindowGroup {
            WrpSampleView(store: .init(
                initialState: .init(),
                reducer: .init(),
                environment: .init(serviceProvider: .init())
            ))
        }
    }
}
