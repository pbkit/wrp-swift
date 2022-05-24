public struct DeferThrowingStream<Element>: AsyncSequence {
    public typealias Stream = AsyncThrowingStream<Element, Error>
    
    public var stream: Stream!
    public var continuation: Stream.Continuation!

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
    
    public func finish(throwing error: Error) {
        self.continuation.finish(throwing: error)
    }
    
    public func finish(with element: Element) {
        self.continuation.finish(with: element)
    }
}
