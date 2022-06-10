//
//  WrpSampleAction.swift
//  WrpExample
//
//  Created by Jaeyoung Yoon on 2022/05/31.
//

import Wrp

enum WrpSampleAction: Equatable {
  case onAppear
  case sliderValueChanged(Double)
  case textValueChanged(String)
  case glueClosed

  case getTextValue
  case getTextValueResult(Result<String, Never>)
  case getSliderValue
  case getSliderValueResult(Result<Double, Never>)

  case startServer
  case startServerResult(Result<String, Never>)
  case startClient
  case startClientResult(Result<String, Never>)
}

extension Pbkit_Wrp_Example_WrpExampleServiceWrpClient: Equatable {
  public static func == (lhs: Pbkit_Wrp_Example_WrpExampleServiceWrpClient, rhs: Pbkit_Wrp_Example_WrpExampleServiceWrpClient) -> Bool {
    return false
  }
}
