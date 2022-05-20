import WebKit
import Foundation
import SwiftProtobuf

public class DeferStream<T> {
  let stream: AsyncStream<T>
  var continuation: AsyncStream<T>.Continuation?
    
  init() {
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
    
    func toWrpPayloadString() -> String {
        return String(String.UnicodeScalarView(self.map {v in UnicodeScalar(v)}))
    }
}
