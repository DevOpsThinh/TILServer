import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    app.get("hello", ":name") { req -> String in
        guard let name = req.parameters.get("name") else {
            throw Abort(.internalServerError)
        }
        return "Hi, \(name)!"
    }
    // Register a new route at /api/terminologies
    app.post("api", "terminologies") { req -> EventLoopFuture<Terminology> in
        let term = try req.content.decode(Terminology.self)

        return term.save(on: req.db).map {
            term
        }
    }
}
