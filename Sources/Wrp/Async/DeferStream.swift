public struct DeferStream<Element>: AsyncSequence {
    public typealias Stream = AsyncStream<Element>
    public typealias Continuation = Stream.Continuation

    public var stream: Stream!
    public var continuation: Continuation!

    public init() {
        self.stream = .init { self.continuation = $0 }
    }

    public func makeAsyncIterator() -> Stream.Iterator {
        self.stream.makeAsyncIterator()
    }

    public func yield(_ element: Element) {
        self.continuation.yield(element)
    }

    public func finish() {
        self.continuation.finish()
    }

    public func finish(with element: Element) {
        self.continuation.finish(with: element)
    }
}
