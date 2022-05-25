extension AsyncCompactMapSequence {
    func toAsyncStream() -> AsyncStream<Element> {
        var iterator = self.makeAsyncIterator()
        return AsyncStream<Element> {
            do {
                return try await iterator.next()
            } catch {
                return nil
            }
        }
    }
}
