//
//  CreateTermCatePivot.swift
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
import Fluent

struct CreateTermCatePivot: Migration {
    /// Create the terminology-category-pivot table in the database with columns
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("terminology-category-pivot")
            .id()
            .field("terminologyID", .uuid, .required,
                    .references("terminologies", "id", onDelete: .cascade))
            .field("categoryID", .uuid, .required,

                    .references("categories", "id", onDelete: .cascade))
            .create()
    }
    /// Deletes the table named terminology-category-pivot
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("terminology-category-pivot").delete()
    }
}
