public extension AsyncStream {
    func transform<Transform>(_ transform: @escaping (Element) async -> Transform) -> AsyncStream<Transform> {
        return self.map(transform).toAsyncStream()
    }
}

public extension AsyncStream.Continuation {
    func finish(with value: Element) {
        self.yield(value)
        self.finish()
    }
}
