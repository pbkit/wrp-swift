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
  var sliderValue: Double?
  var isFirstConnection: Bool = true

  func getTextValue(
    request: AsyncStream<Pbkit_Wrp_Example_GetTextValueRequest>,
    context: WrpRequestContext<Pbkit_Wrp_Example_GetTextValueResponse>
  ) async {
    guard let text = text else {
      return
    }

    context.sendHeader([:])
    context.sendMessage(.with {
      $0.text = text
    })
    context.sendTrailer([:])
  }

  func getSliderValue(
    request: AsyncStream<Pbkit_Wrp_Example_GetSliderValueRequest>,
    context: WrpRequestContext<Pbkit_Wrp_Example_GetSliderValueResponse>
  ) async {
    guard let sliderValue = sliderValue else {
      return
    }

    if isFirstConnection {
      context.sendHeader([:])
      isFirstConnection = false
    }
    context.sendMessage(.with {
      $0.value = Int32(sliderValue)
    })
  }
}
