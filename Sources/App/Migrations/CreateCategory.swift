//
//  CreateCategory.swift
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
import Fluent

struct CreateCategory: Migration {
    /// Create the categories table in the database with columns
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    /// Deletes the table named categories
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete()
    }
}
