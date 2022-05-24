extension AsyncThrowingStream.Continuation {
    public func finish(with value: Element) {
        self.yield(value)
        self.finish()
    }
}
