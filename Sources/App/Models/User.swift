//
//  User.swift
//
//  Created by Nguyễn Trường Thịnh on 13/07/2022.
//
import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "users"

    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "username")
    var username: String

    @Children(for: \Terminology.$user)
    var terminologies: [Terminology]

    init() { }

    init(id: UUID? = nil, name: String, username: String) {
        self.name = name
        self.username = username
    }
}


