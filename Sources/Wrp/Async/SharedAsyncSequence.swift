// SharedAsyncSequence
// https://github.com/reddavis/Asynchrone/blob/main/Asynchrone/Source/Sequences/SharedAsyncSequence.swift
public struct SharedAsyncSequence<Base: AsyncSequence>: AsyncSequence {
    public typealias AsyncIterator = AsyncThrowingStream<Base.Element, Error>.Iterator
    public typealias Element = Base.Element

    private var base: Base
    private let manager: SubSequenceManager<Base>

    public init(_ base: Base) {
        self.base = base
        self.manager = SubSequenceManager<Base>(base)
    }

    public func makeAsyncIterator() -> AsyncThrowingStream<Base.Element, Error>.Iterator {
        self.manager.makeAsyncIterator()
    }
}

private actor SubSequenceManager<Base: AsyncSequence> {
    fileprivate typealias Element = Base.Element

    private var base: Base
    private var sequences: [DeferThrowingStream<Base.Element>] = []
    private var subscriptionTask: Task<Void, Never>?

    fileprivate init(_ base: Base) {
        self.base = base
    }

    deinit {
        self.subscriptionTask?.cancel()
    }

    fileprivate nonisolated func makeAsyncIterator() -> DeferThrowingStream<Base.Element>.AsyncIterator {
        let sequence = DeferThrowingStream<Base.Element>()
        Task { [sequence] in
            await self.add(sequence: sequence)
        }

        return sequence.makeAsyncIterator()
    }

    private func add(sequence: DeferThrowingStream<Base.Element>) {
        self.sequences.append(sequence)
        self.subscribeToBaseSequenceIfNeeded()
    }

    private func subscribeToBaseSequenceIfNeeded() {
        guard self.subscriptionTask == nil else { return }

        self.subscriptionTask = Task { [weak self, base] in
            guard let self = self else { return }

            guard !Task.isCancelled else {
                await self.sequences.forEach {
                    $0.finish(throwing: CancellationError())
                }
                return
            }

            do {
                for try await value in base {
                    await self.sequences.forEach { $0.yield(value) }
                }

                await self.sequences.forEach { $0.finish() }
            } catch {
                await self.sequences.forEach { $0.finish(throwing: error) }
            }
        }
    }
}

public extension AsyncSequence {
    func shared() -> SharedAsyncSequence<Self> {
        .init(self)
    }
}
