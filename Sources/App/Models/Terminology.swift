//
//  Terminology.swift
//
//  Created by Nguyễn Trường Thịnh on 12/07/2022.
//
import Vapor
import Fluent

final class Terminology: Model {
    static let schema = "terminologies"

    @ID
    var id: UUID?

    @Field(key: "short")
    var short: String

    @Field(key: "long")
    var long: String

    init() {}

    init(id: UUID? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}

extension Terminology: Content {}
