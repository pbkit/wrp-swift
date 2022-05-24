extension AsyncStream {
    public func transform<Transform>(_ transform: @escaping (Element) async -> Transform ) -> AsyncStream<Transform> {
        return self.map(transform).toAsyncStream()
    }
}

extension AsyncStream.Continuation {
    public func finish(with value: Element) {
        self.yield(value)
        self.finish()
    }
}
