//
//  WrpSampleView.swift
//  WrpExample
//
//  Created by Jaeyoung Yoon on 2022/05/31.
//

import ComposableArchitecture
import Logging
import SwiftUI
import Wrp

// MARK: View

struct WrpSampleView: View {
    @ObservedObject
    private var viewStore: WrpSampleViewStore
    private let store: WrpSampleStore

    let url: String = "https://pbkit.dev/wrp-example"

    init(store: WrpSampleStore) {
        self.viewStore = ViewStore(store)
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: 0) {
                Text("Bidirectional (both server/client)").fontWeight(.semibold)

                VStack(alignment: .center, spacing: 0) {
                    VStack {
                        Divider()
                        Text("Server Inputs").fontWeight(.semibold)
                        HStack {
                            Text("Text")
                            TextField(
                                "TextValue",
                                text: viewStore.binding(
                                    get: \.textValue,
                                    send: WrpSampleAction.textValueChanged
                                )
                            )
                        }
                        HStack {
                            Text("Slider")
                            Slider(
                                value: viewStore.binding(
                                    get: \.sliderValue,
                                    send: WrpSampleAction.sliderValueChanged
                                ),
                                in: 0 ... 100
                            )
                        }
                        Divider()
                    }
                    .padding(.top)

                    VStack {
                        Text("Server Response").fontWeight(.semibold)
                        VStack(alignment: .leading) {
                            Text("TextValue: \(viewStore.responseTextValue)")
                            HStack {
                                Spacer()
                            }
                            Text("SliderValue: \(viewStore.responseSliderValue)")
                        }
                        HStack {
                            Button("GetTextValue", action: {
                                viewStore.send(.getTextValue)
                            }).buttonStyle(
                                WrpButtonStyle(color: Color.blue.opacity(0.7))
                            )
                            Button("GetSliderValue", action: {
                                viewStore.send(.getSliderValue)
                            }).buttonStyle(
                                WrpButtonStyle(color: Color.orange.opacity(0.7))
                            )
                        }
                    }.padding([.top])
                }.padding()

                Divider()

                WrpView(
                    urlString: self.url,
                    glue: viewStore.glue,
                    onGlueReconnect: {
                        viewStore.send(.glueReconnected)
                    }
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

// MARK: Store

typealias WrpSampleStore = Store<
    WrpSampleState,
    WrpSampleAction
>

// MARK: ViewStore

typealias WrpSampleViewStore = ViewStore<
    WrpSampleState,
    WrpSampleAction
>

#if DEBUG
struct WrpServerAppViewPreview: PreviewProvider {
    static var previews: some View {
        WrpSampleView(store: .init(
            initialState: .init(),
            reducer: .init(),
            environment: .init(serviceProvider: .init())
        ))
    }
}
#endif
