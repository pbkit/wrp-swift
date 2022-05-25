public extension AsyncThrowingStream.Continuation {
    func finish(with value: Element) {
        self.yield(value)
        self.finish()
    }
}
