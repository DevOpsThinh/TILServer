import Fluent
import Vapor

func routes(_ app: Application) throws {

    let terminologiesController = TerminologiesController()
    let usersController = UsersController()

    // To hook up the routes
    try app.register(collection: terminologiesController)
    try app.register(collection: usersController)
}
