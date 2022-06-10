//
//  WrpSampleState.swift
//  WrpExample
//
//  Created by Jaeyoung Yoon on 2022/05/31.
//

import ComposableArchitecture
import Wrp

struct WrpSampleState: Equatable {
  var sliderValue: Double = 0.0
  var textValue: String = ""
  var responseTextValue: String = ""
  var responseSliderValue: Int = 0
  var glue: WrpGlue = .init()
  var client: WrpClient?
}

extension WrpGlue: Equatable {
  public static func == (lhs: WrpGlue, rhs: WrpGlue) -> Bool {
    return false
  }
}

extension WrpClient: Equatable {
  public static func == (lhs: WrpClient, rhs: WrpClient) -> Bool {
    return false
  }
}
