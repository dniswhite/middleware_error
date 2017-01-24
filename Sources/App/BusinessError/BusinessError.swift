import Vapor
import HTTP

// borrowed this from the AbortError prototype and 
// made some changes for my own implementation
public protocol BusinessErrorProtocol: Error {
    /// An integer representation of the error.
    var code: Int { get }
    
    /// The HTTP status code to return.
    var status: Status { get }
}

public enum BusinessError: Swift.ErrorType {
    case businessFault
    case businessException
    case businessWarning
    case businessBadRequest
    case businessDevelopment
    case custom(status: Status, description: String)
}

extension BusinessError: CustomStringConvertible, BusinessErrorProtocol {
    /// An integer representation of the error.
    public var code: Int {
        switch self {
            case .businessBadRequest:
                return 400
            case .businessException:
                return 400
            case .businessFault:
                return 500
            case .businessWarning:
                return 200
            case .businessDevelopment:
                return 501
            case .custom(status: let status, description: _):
                return status.statusCode
        }
    }

    /// The HTTP status code to return.
    public var status: Status {
        switch self {
            case .businessBadRequest:
                return .badRequest
            case .businessException:
                return .badRequest
            case .businessFault:
                return .internalServerError
            case .businessWarning:
                return .badRequest
            case .businessDevelopment:
                return .notImplemented
            case .custom(status: let status, description: _):
                return status
        }
    }

    // get a message that can be sent back to user
    public var description: String {
        switch self {
            case .businessBadRequest:
                return "Bad Request for business framework was made."
            case .businessException:
                return "Business exception has occured while processing request."
            case .businessFault:
                return "A Fault condition was encountered with the request."
            case .businessWarning:
                return "Request was stopped due to a warning that needs to be reviewed."
            case .businessDevelopment:
                return "Request was stopped because this is something we are still working on"
            case .custom(status: _, description: let description):
                return description
        }
    }
}
