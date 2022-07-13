//
//  CreateUser.swift
//
//  Created by Nguyễn Trường Thịnh on 13/07/2022.
//
import Fluent

struct CreateUser: Migration {
    /// Create the users table in the database with columns
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }
    /// Deletes the table named users
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
