import Vapor
import HTTP

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("hello") { request in
    throw BusinessError.businessException
}


drop.resource("posts", PostController())

let businessMiddleware = BusinessErrorsMiddleware(droplet: drop, errorViews: [Status.badRequest: "Error/badrequest", Status.internalServerError: "Error/error", Status.notImplemented: "Error/noimpl"])
drop.middleware.append(businessMiddleware)

drop.run()
