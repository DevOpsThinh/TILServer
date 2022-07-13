import Fluent
import Vapor

func routes(_ app: Application) throws {

    let terminologiesController = TerminologiesController()

    try app.register(collection: terminologiesController)
}
