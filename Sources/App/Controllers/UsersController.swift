//
//  UsersController.swift
//
//  Created by Nguyễn Trường Thịnh on 13/07/2022.
//
import Vapor

struct UsersController: RouteCollection {
    /// Register route handlers
    func boot(routes: RoutesBuilder) throws {
        // A route group for the path /api/users.
        let usersRoutes = routes.grouped("api", "users")

        // Register a new route at /api/users for retrieve all users.
        usersRoutes.get(use: getAllHandler)
        // Register a new route at /api/users for create a single user.
        usersRoutes.post(use: createHandler)
        // Register a new route at /api/users/<id> for retrieve a single user.
        usersRoutes.get(":userID", use: getHandler)
        // Register a new route at /api/users/<id>/terminologies for retrieve terminologies list.
        usersRoutes.get(":userID", "terminologies", use: getTermsHandler)


    }
    /// A route handler: Makes a GET request to /api/users
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    /// A route handler: Makes a POST request to /api/users
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    /// A route handler: Makes a GET request to /api/users/<ID>
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    /// A route handler: Makes a GET request to /api/users/<ID>/terminologies
    func getTermsHandler(_ req: Request) throws -> EventLoopFuture<[Terminology]> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$terminologies.get(on: req.db)
            }
    }

}
