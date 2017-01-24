import Vapor
import HTTP

public class BusinessErrorsMiddleware : Middleware {
    var droplet = Droplet()
    var errorViews = [Status:String]()
    
    public init(droplet drop: Droplet, errorViews views: [Status:String]) {
        droplet = drop
        errorViews = views
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch let error as  BusinessError {
            return try handleError(request: request, error: error)
        }
    }
    
    private func handleError(request: Request, error: BusinessError) throws -> Response {
        if request.accept.prefers("html") {
            return try handleViewResponse(request: request, error: error)
        } else {
            return try handleJSONResponse(request: request, error: error)
        }
    }
    
    private func handleViewResponse(request: Request, error: BusinessError) throws -> Response {
        let viewName = errorViews[error.status]
        
        if viewName.isNilOrEmpty {
            throw Abort.notFound
        }
        
        let view = try droplet.view.make(viewName!, ["message": error.description, "code": error.code])
        
        let data = try view.makeBytes()
        let response = Response(status: error.status, body: .data(data))
        response.headers["Content-Type"] = "text/html; charset=utf-8"
        return response
    }
    
    private func handleJSONResponse(request: Request, error: BusinessError) throws -> Response {
        let json = try JSON(node: [
            "error": true,
            "message": "\(error.description)",
            "code": error.code
        ])
        
        let data = try json.makeBytes()
        let response = Response(status: error.status, body: .data(data))
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        return response
    }
}
