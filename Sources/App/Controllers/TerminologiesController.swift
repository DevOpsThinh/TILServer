//
//  TerminologiesController.swift
//
//  Created by Nguyễn Trường Thịnh on 13/07/2022.
//
import Vapor
import Fluent

struct TerminologiesController: RouteCollection {
    /// Register routes
    func boot(routes: RoutesBuilder) throws {
        // A route group for the path /api/terminologies.
        let terminologiesRoutes = routes.grouped("api", "terminologies")

        // Register a new route at /api/terminologies for retrieve all terminologies.
        terminologiesRoutes.get(use: getAllHandler)
        // Register a new route at /api/terminologies for create a single terminology.
        terminologiesRoutes.post(use: createHandler)
        // Register a new route at /api/terminologies/<ID> for retrieve a single terminology.
        terminologiesRoutes.get(":terminologyID", use: getHandler)
        // Register a new route at /api/terminologies/<ID> for update a single terminology.
        terminologiesRoutes.put(":terminologyID", use: updateHandler)
        // Register a new route at /api/terminologies/<ID> for remove a single terminology.
        terminologiesRoutes.delete(":terminologyID", use: deleteHandler)
        // Register a new route at /api/terminologies/search for retrieve the search term (search all the terminologies).
        terminologiesRoutes.get("search", use: searchHandler)
        // Register a new route at /api/terminologies/first for retrieve the first result.
        terminologiesRoutes.get("first", use: getFirstHandler)
        // Register a new route at /api/terminologies/sorted for sort the results of queries before returning them.
        terminologiesRoutes.get("sorted", use: sortedHandler)

    }
    /// A route handler: Makes a GET request to /api/terminologies
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Terminology]> {
        Terminology.query(on: req.db).all()
    }
    /// A route handler: Makes a POST request to /api/terminologies
    func createHandler(_ req: Request) throws -> EventLoopFuture<Terminology> {
        let term = try req.content.decode(Terminology.self)
        return term.save(on: req.db).map { term }
    }
    /// A route handler: Makes a GET request to /api/terminologies/<ID>
    func getHandler(_ req: Request) throws -> EventLoopFuture<Terminology> {
        Terminology
            .find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    /// A route handler: Makes a PUT request to /api/terminologies/<ID>
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Terminology> {
        let updatedTerm = try req.content.decode(Terminology.self)
        return Terminology
            .find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { term in
                term.short = updatedTerm.short
                term.long = updatedTerm.long
                return term.save(on: req.db).map { term }
            }
    }
    /// A route handler: Makes a DELETE request to /api/terminologies/<ID>
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Terminology
            .find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { term in
                term.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    /// A route handler: Makes a GET request to /api/terminologies/search
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Terminology]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Terminology
            .query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }.all()
    }
    /// A route handler: Makes a GET request to /api/terminologies/first
    func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Terminology> {
        return Terminology
            .query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    /// A route handler: Makes a GET request to /api/terminologies/sorted
    func sortedHandler(_ req: Request) throws -> EventLoopFuture<[Terminology]> {
        return Terminology
            .query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
}
