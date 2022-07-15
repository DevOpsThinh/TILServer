//
//  Categogy.swift
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
import Fluent
import Vapor
import Foundation

final class Category: Model, Content {
    static let schema = "categories"

    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Siblings(through: TermCatePivot.self, from: \.$category, to: \.$terminology)
    var terminologies: [Terminology]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
