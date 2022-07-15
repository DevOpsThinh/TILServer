import Fluent
import Vapor

func routes(_ app: Application) throws {


    let usersController = UsersController()
    let terminologiesController = TerminologiesController()
    let categoriesController = CategoriesController()

    // To hook up the routes
    try app.register(collection: usersController)
    try app.register(collection: terminologiesController)
    try app.register(collection: categoriesController)

}
