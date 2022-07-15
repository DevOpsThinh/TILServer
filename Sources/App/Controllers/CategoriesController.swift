//
//  CategoriesController.swift
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
import Vapor
import Fluent

struct CategoriesController: RouteCollection {
    /// Register route handlers
    func boot(routes: RoutesBuilder) throws {
        // A route group for the path /api/categories.
        let categoriesRoutes = routes.grouped("api", "categories")
        // Register a new route at /api/categories for create a single category.
        categoriesRoutes.post(use: createHandler)
        // Register a new route at /api/categories for retrieve all categories.
        categoriesRoutes.get(use: getAllHandler)
        // Register a new route at /api/categories/<id> for retrieve a single categories.
        categoriesRoutes.get(":categoryID", use: getHandler)
        // Register a new route at /api/categories/<id>/terminologies for retrieve the terminologies list.
        categoriesRoutes.get(":categoryID", "terminologies", use: getTerminologiesHandler)
    }
    /// A route handler: Makes a GET request to /api/categories
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category
            .query(on: req.db)
            .all()
    }
    /// A route handler: Makes a POST request to /api/categories
    func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category.save(on: req.db).map { category }
    }
    /// A route handler: Makes a GET request to /api/categories/<ID>
    func getHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    /// A route handler: Makes a GET request to /api/categories/<ID>/terminologies
    func getTerminologiesHandler(_ req: Request) throws -> EventLoopFuture<[Terminology]> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { cate in
                cate.$terminologies.get(on: req.db)
            }
    }
}
