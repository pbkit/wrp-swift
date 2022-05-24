import Foundation
import SwiftProtobuf
import WebKit

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

    func encode() -> String {
        let str = String(data: self, encoding: .isoLatin1)!
        let json = try! JSONSerialization.data(withJSONObject: str, options: .fragmentsAllowed)
        return String(data: json, encoding: .utf8)!
    }
}
