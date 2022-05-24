import Foundation

public struct Defer<Element>: AsyncSequence {
    public typealias Stream = AsyncThrowingStream<Element, Error>
    
    public var stream: Stream!
    private var flag = false
    private var value: Element?
    private var continuation: Stream.Continuation!
    
    public init() {
        self.stream = .init { self.continuation = $0 }
    }
    
    public func makeAsyncIterator() -> Stream.Iterator {
        self.stream.makeAsyncIterator()
    }
    
    public mutating func resolve(_ element: Element) {
        defer {
            self.value = element
            self.flag = true
        }
        self.continuation.finish(with: element)
    }
    
    public mutating func reject(throwing error: Error) {
        defer {
            self.flag = true
        }
        self.continuation.finish(throwing: error)
    }
    
    public func value() async -> Element? {
        guard !flag else { return self.value }
        var iterator = self.stream.makeAsyncIterator()
        return try? await iterator.next()
    }
}
