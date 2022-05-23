import Foundation
import SwiftProtobuf

private let _protobuf_package = "pbkit.wrp"
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

public struct Pbkit_Wrp_WrpMessage {
    public var message: Pbkit_Wrp_WrpMessage.OneOf_Message?

    public var hostInitialize: Pbkit_Wrp_WrpHostMessage_Initialize {
        get {
            if case .hostInitialize(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .hostInitialize(newValue) }
    }

    public var hostError: Pbkit_Wrp_WrpHostMessage_Error {
        get {
            if case .hostError(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .hostError(newValue) }
    }

    public var hostResStart: Pbkit_Wrp_WrpHostMessage_ResStart {
        get {
            if case .hostResStart(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .hostResStart(newValue) }
    }

    public var hostResPayload: Pbkit_Wrp_WrpHostMessage_ResPayload {
        get {
            if case .hostResPayload(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .hostResPayload(newValue) }
    }

    public var hostResFinish: Pbkit_Wrp_WrpHostMessage_ResFinish {
        get {
            if case .hostResFinish(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .hostResFinish(newValue) }
    }

    public var guestReqStart: Pbkit_Wrp_WrpGuestMessage_ReqStart {
        get {
            if case .guestReqStart(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .guestReqStart(newValue) }
    }

    public var guestReqPayload: Pbkit_Wrp_WrpGuestMessage_ReqPayload {
        get {
            if case .guestReqPayload(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .guestReqPayload(newValue) }
    }

    public var guestReqFinish: Pbkit_Wrp_WrpGuestMessage_ReqFinish {
        get {
            if case .guestReqFinish(let v)? = self.message { return v }
            return .init()
        }
        set { self.message = .guestReqFinish(newValue) }
    }

    public enum OneOf_Message: Equatable {
        case hostInitialize(Pbkit_Wrp_WrpHostMessage_Initialize)
        case hostError(Pbkit_Wrp_WrpHostMessage_Error)
        case hostResStart(Pbkit_Wrp_WrpHostMessage_ResStart)
        case hostResPayload(Pbkit_Wrp_WrpHostMessage_ResPayload)
        case hostResFinish(Pbkit_Wrp_WrpHostMessage_ResFinish)
        case guestReqStart(Pbkit_Wrp_WrpGuestMessage_ReqStart)
        case guestReqPayload(Pbkit_Wrp_WrpGuestMessage_ReqPayload)
        case guestReqFinish(Pbkit_Wrp_WrpGuestMessage_ReqFinish)

        #if !swift(>=4.1)
        public static func == (lhs: Pbkit_Wrp_WrpMessage.OneOf_Message, rhs: Pbkit_Wrp_WrpMessage.OneOf_Message) -> Bool {
            switch (lhs, rhs) {
            case (.hostInitialize, .hostInitialize): return {
                    guard case .hostInitialize(let l) = lhs, case .hostInitialize(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.hostError, .hostError): return {
                    guard case .hostError(let l) = lhs, case .hostError(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.hostResStart, .hostResStart): return {
                    guard case .hostResStart(let l) = lhs, case .hostResStart(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.hostResPayload, .hostResPayload): return {
                    guard case .hostResPayload(let l) = lhs, case .hostResPayload(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.hostResFinish, .hostResFinish): return {
                    guard case .hostResFinish(let l) = lhs, case .hostResFinish(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.guestReqStart, .guestReqStart): return {
                    guard case .guestReqStart(let l) = lhs, case .guestReqStart(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.guestReqPayload, .guestReqPayload): return {
                    guard case .guestReqPayload(let l) = lhs, case .guestReqPayload(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            case (.guestReqFinish, .guestReqFinish): return {
                    guard case .guestReqFinish(let l) = lhs, case .guestReqFinish(let r) = rhs else { preconditionFailure() }
                    return l == r
                }()
            default:
                return false
            }
        }
        #endif
    }

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Pbkit_Wrp_WrpMessage: @unchecked Sendable {}
extension Pbkit_Wrp_WrpMessage.OneOf_Message: @unchecked Sendable {}
#endif

extension Pbkit_Wrp_WrpMessage: SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".WrpMessage"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "Host_Initialize"),
        2: .same(proto: "Host_Error"),
        3: .same(proto: "Host_ResStart"),
        4: .same(proto: "Host_ResPayload"),
        5: .same(proto: "Host_ResFinish"),
        6: .same(proto: "Guest_ReqStart"),
        7: .same(proto: "Guest_ReqPayload"),
        8: .same(proto: "Guest_ReqFinish"),
    ]
}

extension Pbkit_Wrp_WrpMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase {
    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try {
                    var v: Pbkit_Wrp_WrpHostMessage_Initialize?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .hostInitialize(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .hostInitialize(v)
                    }
                }()
            case 2: try {
                    var v: Pbkit_Wrp_WrpHostMessage_Error?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .hostError(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .hostError(v)
                    }
                }()
            case 3: try {
                    var v: Pbkit_Wrp_WrpHostMessage_ResStart?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .hostResStart(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .hostResStart(v)
                    }
                }()
            case 4: try {
                    var v: Pbkit_Wrp_WrpHostMessage_ResPayload?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .hostResPayload(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .hostResPayload(v)
                    }
                }()
            case 5: try {
                    var v: Pbkit_Wrp_WrpHostMessage_ResFinish?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .hostResFinish(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .hostResFinish(v)
                    }
                }()
            case 6: try {
                    var v: Pbkit_Wrp_WrpGuestMessage_ReqStart?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .guestReqStart(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .guestReqStart(v)
                    }
                }()
            case 7: try {
                    var v: Pbkit_Wrp_WrpGuestMessage_ReqPayload?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .guestReqPayload(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .guestReqPayload(v)
                    }
                }()
            case 8: try {
                    var v: Pbkit_Wrp_WrpGuestMessage_ReqFinish?
                    var hadOneofValue = false
                    if let current = self.message {
                        hadOneofValue = true
                        if case .guestReqFinish(let m) = current { v = m }
                    }
                    try decoder.decodeSingularMessageField(value: &v)
                    if let v = v {
                        if hadOneofValue { try decoder.handleConflictingOneOf() }
                        self.message = .guestReqFinish(v)
                    }
                }()
            default: break
            }
        }
    }
}

public extension Pbkit_Wrp_WrpMessage {
    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        switch self.message {
        case .hostInitialize?: try {
                guard case .hostInitialize(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
            }()
        case .hostError?: try {
                guard case .hostError(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
            }()
        case .hostResStart?: try {
                guard case .hostResStart(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
            }()
        case .hostResPayload?: try {
                guard case .hostResPayload(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
            }()
        case .hostResFinish?: try {
                guard case .hostResFinish(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
            }()
        case .guestReqStart?: try {
                guard case .guestReqStart(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
            }()
        case .guestReqPayload?: try {
                guard case .guestReqPayload(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
            }()
        case .guestReqFinish?: try {
                guard case .guestReqFinish(let v)? = self.message else { preconditionFailure() }
                try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
            }()
        default: break
        }
        try self.unknownFields.traverse(visitor: &visitor)
    }
}

public extension Pbkit_Wrp_WrpMessage {
    static func == (lhs: Pbkit_Wrp_WrpMessage, rhs: Pbkit_Wrp_WrpMessage) -> Bool {
        if lhs.message != rhs.message { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
