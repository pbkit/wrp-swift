import Foundation

struct WrpGlueError: Error {
    enum ErrorKind {
        case disposedError
    }
    
    let kind: ErrorKind
}

public class WrpGlue {
    private let queue: DeferStream<Data> = .init()
    private var disposed = false
    
    init() { }
    
    public func dispose() {
        disposed = true
    }
    
    public func recv(_ data: Data) throws {
        guard !disposed else {
            throw WrpGlueError(kind: .disposedError)
        }
        print("WrpGlue(recv): Received data")
        queue.continuation?.yield(data)
    }
    
    public func read() -> AsyncStream<Data> {
        return self.queue.stream
    }
}
