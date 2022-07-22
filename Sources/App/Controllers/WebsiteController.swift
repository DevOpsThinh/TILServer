//
//  WebsiteController.swift
//
//  Created by Nguyễn Trường Thịnh on 22/07/2022.
//
import Vapor
/// Hold all the website routes
struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Register a new route at / for render the index template
        routes.get(use: indexHandler)
        // Register a new route at /terminologies/<id>/ for render the terminolgy template
        routes.get("terminologies", ":terminologyID", use: termHandler)
        // Register a new route at /user/<id>/ for render the user template
        routes.get("users", ":userID", use: userHandler)
        // Register a new route at /user/for render the allUsers template
        routes.get("users", use: allUsersHandler)
    }
    /// A route handler: Makes a GET request to / (root path)
    func indexHandler (_ req: Request) -> EventLoopFuture<View> {
        Terminology.query(on: req.db).all().flatMap { terms in
            let context = IndexContext(title: "Home", terminologies: terms)
            return  req.view.render("index", context)
        }
    }
    /// A route handler: Makes a GET request to /terminologies/<id>/
    func termHandler(_ req: Request) -> EventLoopFuture<View> {
        Terminology
            .find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { term in
                term.$user.get(on: req.db).flatMap { user in
                    let context = TermContext(title: term.short, terminology: term, user: user)
                    return req.view.render("terminology", context)
                }
        }
    }
    /// A route handler: Makes a GET request to /users/<id>/
    func userHandler(_ req: Request) -> EventLoopFuture<View> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$terminologies.get(on: req.db).flatMap { terms in
                    let context = UserContext(
                        title: user.name,
                        user: user,
                        terminologies: terms)
                    return req.view.render("user", context)
                }
            }
    }
    /// A route handler: Makes a GET request to /users/
    func allUsersHandler(_ req: Request) -> EventLoopFuture<View> {
        User
            .query(on: req.db)
            .all()
            .flatMap { users in
                let context = AllUsersContext(
                    title: "All Users", users: users
                )
                return req.view.render("allUsers", context)
            }
    }
}

struct IndexContext: Encodable {
    let title: String
    let terminologies: [Terminology]
}

struct TermContext: Encodable {
    let title: String
    let terminology: Terminology
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let terminologies: [Terminology]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}
