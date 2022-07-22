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
        // Register a new route at / for render the terminolgy template
        routes.get("terminologies", ":terminologyID", use: termHandler)
    }
    /// A route handler: Makes a GET request to / (root path)
    func indexHandler (_ req: Request) throws -> EventLoopFuture<View> {
        Terminology.query(on: req.db).all().flatMap { terms in
            let termsData = terms.isEmpty ? nil : terms
            let context = IndexContext(title: "Home", terminologies: termsData)
            return  req.view.render("index", context)
        }
    }
    /// A route handler: Makes a GET request to /terminologies/<id>/user
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
}

struct IndexContext: Encodable {
    let title: String
    let terminologies: [Terminology]?
}

struct TermContext: Encodable {
    let title: String
    let terminology: Terminology
    let user: User
}
