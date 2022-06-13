import SwiftUI
import Wrp

class WrpExampleServiceProvider: Pbkit_Wrp_Example_WrpExampleServiceWrpProvider {
    var textValue: Binding<String>
    var sliderValueStream: AsyncStream<Double>

    init(
        textValue: Binding<String>,
        sliderValueStream: AsyncStream<Double>
    ) {
        self.textValue = textValue
        self.sliderValueStream = sliderValueStream
    }

    func getTextValue(
        request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>,
        context: WrpRequestContext<Pbkit_Wrp_Example_GetTextValueResponse>
    ) async {
        context.sendHeader([:])
        context.sendMessage(.with {
            $0.text = textValue.wrappedValue
        })
        context.sendTrailer([:])
    }

    func getSliderValue(
        request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>,
        context: WrpRequestContext<Pbkit_Wrp_Example_GetSliderValueResponse>
    ) async {
        context.sendHeader([:])
        for await sliderValue in self.sliderValueStream {
            context.sendMessage(.with {
                $0.value = Int32(sliderValue)
            })
        }
    }
}

class WrpExampleServiceProviderForTCA: Pbkit_Wrp_Example_WrpExampleServiceWrpProvider {
    var text: String?

    private var _sliderValue: Double?
    private let sliderValueStream: DeferStream<Double> = .init()
    private var sliderValueSequence: SharedAsyncSequence<AsyncStream<Double>>

    init() {
        self.sliderValueSequence = self.sliderValueStream.stream.shared()
    }

    var sliderValue: Double? {
        get { self._sliderValue }
        set {
            self._sliderValue = newValue
            if let value = newValue {
                self.sliderValueStream.yield(value)
            }
        }
    }

    func getTextValue(
        request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>,
        context: WrpRequestContext<Pbkit_Wrp_Example_GetTextValueResponse>
    ) async {
        context.sendHeader([:])
        if let text = text {
            context.sendMessage(.with {
                $0.text = text
            })
        }
        context.sendTrailer([:])
    }

    func getSliderValue(
        request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>,
        context: WrpRequestContext<Pbkit_Wrp_Example_GetSliderValueResponse>
    ) async {
        context.sendHeader([:])
        do {
            for try await sliderValue in self.sliderValueSequence {
                context.sendMessage(.with {
                    $0.value = Int32(sliderValue)
                })
            }
        } catch {}
        context.sendTrailer([:])
    }
}
