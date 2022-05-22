import WebKit
import Foundation
import SwiftProtobuf

public class DeferStream<T> {
  public let stream: AsyncStream<T>
  public var continuation: AsyncStream<T>.Continuation!
    
  public init() {
    var _continuataion: AsyncStream<T>.Continuation?
    self.stream = AsyncStream { continuation in
      _continuataion = continuation
    }
    self.continuation = _continuataion
  }
}

extension Data {
    mutating func set(_ other: Data) {
        self.removeAll(keepingCapacity: true)
        self.append(other)
    }
    
    // @TODO: Make it throws
    mutating func popFirst(_ k: Int) -> Data {
        let first = self.prefix(k)
        self.removeFirst(k)
        return first
    }
    
    // "\r\n" is a grapheme cluster so escape \r (which value is 13) especially
    func toWrpPayloadString() -> String {
        return String(String.UnicodeScalarView(self.map {v in UnicodeScalar(v)})).unicodeScalars.map { scalar in
            if scalar.value == 13 { return "\\r" }
            return String(scalar)
        }.joined()
    }
}
