public class WrpMethodIdentifier {
    let serviceName: Substring
    let methodName: Substring
    var fullName: String { "\(self.serviceName)/\(self.methodName)" }

    var description: String { self.fullName }

    init(identifier: String) throws {
        let splitted = identifier.split(separator: "/")
        guard let serviceName = splitted.first,
              let methodName = splitted.last
        else {
            throw SplitError.invalidInput(identifier)
        }
        self.serviceName = serviceName
        self.methodName = methodName
    }

    enum SplitError: Error {
        case invalidInput(String)
    }
}
