public struct DeferJust<Element>: AsyncSequence {
    public typealias Stream = AsyncThrowingStream<Element, Error>
    public typealias Continuation = Stream.Continuation

    public var stream: Stream!
    public var continuation: Continuation!

    public init() {
        self.stream = .init { self.continuation = $0 }
    }

    public init(_ element: Element) {
        self.stream = .init {
            $0.finish(with: element)
            self.continuation = $0
        }
    }

    public func toJust() -> Just<Element> {
        return .init {
            try? await self.stream.first()
        }
    }

    public func resolve(_ element: Element) {
        self.continuation.finish(with: element)
    }

    public func reject(throwing error: Error? = nil) {
        self.continuation.finish(throwing: error)
    }

    public func makeAsyncIterator() -> Stream.Iterator {
        self.stream.makeAsyncIterator()
    }
}
