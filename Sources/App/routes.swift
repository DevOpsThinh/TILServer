import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello", ":name") { req -> String in
        guard let name = req.parameters.get("name") else {
            throw Abort(.internalServerError)
        }
        return "Hi, \(name)!"
    }
    /// Register a new route at /api/terminologies for create a single terminology using a POST request
    app.post("api", "terminologies") { req -> EventLoopFuture<Terminology> in

        let term = try req.content.decode(Terminology.self)
        // Save the Terminology model using Fluent
        return term.save(on: req.db).map { term }
    }
    /// Register a new route at /api/terminologies for retrieve all terminologies using a GET request
    app.get("api", "terminologies") { req -> EventLoopFuture<[Terminology]> in

        Terminology.query(on: req.db).all()
    }
    /// Register a new route at /api/terminologies/<ID> for retrieve a single terminology using a GET request
    app.get("api", "terminologies", ":terminologyID") { req -> EventLoopFuture<Terminology> in

        Terminology.find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    /// Register a new route at /api/terminologies/<ID> for update  a single terminology using a PUT request
    app.put("api", "terminologies", ":terminologyID") { req -> EventLoopFuture<Terminology> in

        let updatedTerm = try req.content.decode(Terminology.self)

        return Terminology.find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { term in
                term.short = updatedTerm.short
                term.long = updatedTerm.long

                return term.save(on: req.db).map { term }
            }
    }
    /// Register a new route at /api/terminologies/<ID> for delete  a single terminology using a DELETE request
    app.delete("api", "terminologies", ":terminologyID") { req -> EventLoopFuture<HTTPStatus> in

        Terminology.find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { term in
                term.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    /// Register a new route at /api/terminologies/search for retrieve the search term (search all the terminologies) using a GET request via Fluent's filter() function
    app.get("api", "terminologies", "search") { req -> EventLoopFuture<[Terminology]> in

        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Terminology
            .query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }
    /// Register a new route at /api/terminologies/first for retrieve the search term (the first result) using a GET request via Fluent's first() function
    app.get("api", "terminologies", "first") { req -> EventLoopFuture<Terminology> in

        Terminology
            .query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))

    }
    /// Register a new route at /api/terminologies/sorted for sort the results of queries before returning them, using a GET request via Fluent's sort() function
    app.get("api", "terminologies", "sorted") { req -> EventLoopFuture<[Terminology]> in

        Terminology
            .query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
}
