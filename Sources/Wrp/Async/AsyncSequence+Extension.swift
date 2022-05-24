extension AsyncSequence {
    public func first() async rethrows -> Element? {
        try await self.first { _ in true }
    }
}
