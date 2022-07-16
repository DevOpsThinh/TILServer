//
//  Models+Testable.swift
//
//  Test extensions
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
@testable import App
import Fluent

extension User {
    static func create(
        name: String = "Adam",
        username:String = "adam_eva",
        on database: Database) throws -> User {
            let user = User(name: name, username: username)
            try user.save(on: database).wait()
            return user
        }
}

extension Terminology {
    static func create(
        short: String = "TIL",
        long: String = "Terminology I Learned",
        user: User? = nil,
        on database: Database
    ) throws -> Terminology {
        var terminologiesUser = user

        if (terminologiesUser == nil) {
            terminologiesUser = try User.create(on: database)
        }

        let terminology = Terminology(
            short: short,
            long: long,
            userID: terminologiesUser!.id!
        )
        try terminology.save(on: database).wait()
        return terminology
    }
}

extension App.Category {
    static func create(
        name: String = "AnyThing",
        on database: Database
    ) throws -> App.Category {
            let category = Category(name: name)
            try category.save(on: database).wait()
            return category
    }
}
