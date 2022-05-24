public struct Just<Element>: AsyncSequence {
    private let deferJust: DeferJust<Element> = .init()

    public init(
        _ build: (Continuation) -> Void
    ) {
        build(Continuation.init(continuation: deferJust.continuation))
    }
    
    public init(
        unfolding produce: @escaping () async -> Element?
    ) {
        Task { [self] in
            guard let value = await produce() else {
                self.deferJust.reject()
                return
            }
            self.deferJust.resolve(value)
        }
    }
    
    public func makeAsyncIterator() -> DeferJust<Element>.Stream.Iterator {
        deferJust.makeAsyncIterator()
    }
    
    public struct Continuation: Sendable {
        var continuation: DeferJust<Element>.Stream.Continuation
        public func resolve(_ element: Element) {
            self.continuation.finish(with: element)
        }
        public func reject(throwing error: Error) {
            self.continuation.finish(throwing: error)
        }
        public init(
            continuation: DeferJust<Element>.Stream.Continuation) {
                self.continuation = continuation
            }
    }
}
