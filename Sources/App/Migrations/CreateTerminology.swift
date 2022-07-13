//
//  CreateTerminology.swift
//
//  Created by Nguyễn Trường Thịnh on 12/07/2022.
//
import Fluent

struct CreateTerminology: Migration {
    func prepare(on databse: Database) -> EventLoopFuture<Void> {
        databse.schema("terminologies")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("terminologies").delete()
    }
}
