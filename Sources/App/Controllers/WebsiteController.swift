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
        // Register a new route at /categories/ for render the allCategories template
        routes.get("categories", use: allCatesHandler)
        // Register a new route at /categories/<id> for render the category template
        routes.get("categories", ":categoryID", use: cateHandler)
        // Register a new route at /terminologies/ for render the createTerminology template
        routes.get("terminologies", "create", use: createTermHandler)
        // Register a new route at /terminologies/ for create a terminology & render terminolgy template
        routes.post("terminologies", "create", use: createTermPostHandler)
        // Register a new route at /terminologies/ for render the editTerminology template
        routes.get("terminologies", ":terminologyID", "edit", use: editTermHandler)
        // Register a new route at /terminologies/ for edit a terminology & render the terminolgy template
        routes.post("terminologies", ":terminologyID", "edit", use: editTermPostHandler)
        // Register a new route at /terminologies/ for delete a terminology & render the index template
        routes.post("terminologies", ":terminologyID", "delete", use: deleteTermHandler)
    }
    /// A route handler: Makes a GET request to / (root path)
    func indexHandler (_ req: Request) -> EventLoopFuture<View> {
        Terminology
            .query(on: req.db)
            .all()
            .flatMap { terms in
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
    /// A route handler: Makes a GET request to /categories/
    func allCatesHandler(_ req: Request) -> EventLoopFuture<View> {
        Category
            .query(on: req.db)
            .all()
            .flatMap { cates in
                let context = AllCatesContext(categories: cates)
                return req.view.render("allCategories", context)
            }
    }
    /// A route handler: Makes a GET request to /categories/<id>/
    func cateHandler(_ req: Request) -> EventLoopFuture<View> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { cate in
                cate.$terminologies.get(on: req.db).flatMap { terms in
                    let context = CateContext(title: cate.name, category: cate, terminologies: terms)
                    return req.view.render("category", context)
                }
            }
    }
    /// A route handler: Makes a GET request to /terminologies/
    func createTermHandler(_ req: Request) -> EventLoopFuture<View> {
        User
            .query(on: req.db)
            .all()
            .flatMap { users in
                let context = CreateTermContext(users: users)
                return req.view.render("CreateTerminology", context)
            }
    }
    /// A route handler: Makes a POST request to /terminologies/
    func createTermPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateTermData.self)
        let term = Terminology(short: data.short, long: data.long, userID: data.userID)
        return term.save(on: req.db).flatMapThrowing {
            guard let id = term.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/terminologies/\(id)")
        }
    }
    /// A route handler: Makes a GET request to /terminologies/<id>/
    func editTermHandler(_ req: Request) -> EventLoopFuture<View> {
        let termFuture = Terminology
            .find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let userQuery = User.query(on: req.db).all()
        return termFuture.and(userQuery).flatMap { term, users in
          let context = EditTermContext(terminology: term, users: users)
          return req.view.render("createTerminology", context)
        }
      }
     /// A route handler: Makes a POST request to /terminologies/<id>/
      func editTermPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let updateData = try req.content.decode(CreateTermData.self)
        return Terminology
              .find(req.parameters.get("terminologyID"), on: req.db)
              .unwrap(or: Abort(.notFound))
              .flatMap { term in
                  term.short = updateData.short
                  term.long = updateData.long
                  term.$user.id = updateData.userID
                  guard let id = term.id else {
                    return req.eventLoop.future(error: Abort(.internalServerError))
                  }
                  let redirect = req.redirect(to: "/terminologies/\(id)")
                  return term.save(on: req.db).transform(to: redirect)
        }
      }
    /// A route handler: Makes a POST request to /terminologies/<id>/
    func deleteTermHandler(_ req: Request) -> EventLoopFuture<Response> {
        Terminology
            .find(req.parameters.get("terminologyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { term in
                term.delete(on: req.db).transform(to: req.redirect(to: "/"))
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

struct AllCatesContext: Encodable {
    let title = "All Categories"
    let categories: [Category]
}

struct CateContext: Encodable {
    let title: String
    let category: Category
    let terminologies: [Terminology]
}

struct CreateTermContext: Encodable {
    let title = "New Terminology"
    let users: [User]
}

struct EditTermContext: Encodable {
    let title = "Edit Terminology"
    let terminology: Terminology
    let users: [User]
    let editing = true
}
