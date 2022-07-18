//
//  WrpSampleReducer.swift
//  WrpExample
//
//  Created by Jaeyoung Yoon on 2022/05/31.
//

import Combine
import ComposableArchitecture
import Logging
import Wrp

typealias WrpSampleReducer = Reducer<
    WrpSampleState,
    WrpSampleAction,
    WrpSampleEnvironment
>

extension WrpSampleReducer {
    init() {
        self = Self
            .combine(
                .init { state, action, environment in
                    switch action {
                    case .onAppear:
                        return .merge(
                            .init(value: .startServer),
                            .init(value: .startClient)
                        )

                    case .startServer:
                        var logger = Logger(label: "io.wrp.server")
                        logger.logLevel = .debug
                        let server = WrpServer.create(
                            glue: state.glue,
                            serviceProviders: [environment.serviceProvider],
                            logger: logger
                        )

                        return server.start()
                            .toPublisher()
                            .receive(on: DispatchQueue.main)
                            .replaceError(with: "")
                            .catchToEffect()
                            .map(WrpSampleAction.startServerResult)

                    case .startServerResult(.success):
                        return .none

                    case .startServerResult:
                        return .none

                    case .startClient:
                        var logger = Logger(label: "io.wrp.client")
                        logger.logLevel = .debug
                        let client = WrpClient.create(glue: state.glue, logger: logger)
                        state.client = client

                        return client.start()
                            .toPublisher()
                            .receive(on: DispatchQueue.main)
                            .replaceError(with: "")
                            .catchToEffect()
                            .map(WrpSampleAction.startClientResult)

                    case .startClientResult(.success):
                        return .none

                    case .startClientResult:
                        return .none

                    case .sliderValueChanged(let value):
                        state.sliderValue = value
                        environment.serviceProvider.sliderValue = value
                        return .none

                    case .getSliderValue:
                        guard
                            let client = state.client,
                            let response = try? Pbkit_Wrp_Example_WrpExampleServiceWrpClient(client: client)
                            .getSliderValue(.init())
                            .response
                        else {
                            return .none
                        }

                        return response
                            .toPublisher()
                            .map { Double($0.value) }
                            .replaceError(with: 0.0)
                            .receive(on: DispatchQueue.main)
                            .catchToEffect()
                            .map(WrpSampleAction.getSliderValueResult)

                    case .getSliderValueResult(.success(let value)):
                        state.responseSliderValue = Int(value)
                        return .none

                    case .getSliderValueResult:
                        return .none

                    case .textValueChanged(let value):
                        state.textValue = value
                        environment.serviceProvider.text = value
                        return .none

                    case .getTextValue:
                        guard
                            let client = state.client,
                            let response = try? Pbkit_Wrp_Example_WrpExampleServiceWrpClient(client: client)
                            .getTextValue(.init())
                            .response
                        else {
                            return .none
                        }

                        return response
                            .toPublisher()
                            .map { $0.text }
                            .replaceError(with: "")
                            .catchToEffect()
                            .map(WrpSampleAction.getTextValueResult)

                    case .getTextValueResult(.success(let value)):
                        state.responseTextValue = value
                        return .none

                    case .getTextValueResult:
                        return .none

                    case .glueReconnected:
                        return .merge(
                            .init(value: .startClient),
                            .init(value: .startServer)
                        )
                    }
                }
            )
    }
}
