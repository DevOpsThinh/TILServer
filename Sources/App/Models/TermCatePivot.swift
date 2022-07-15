//
//  TermCatePivot.swift
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
import Fluent
import Foundation

final class TermCatePivot: Model {
    static let schema = "terminology-category-pivot"

    @ID
    var id: UUID?

    @Parent(key: "terminologyID")
    var terminology: Terminology

    @Parent(key: "categoryID")
    var category: Category

    init() { }

    init (id: UUID? = nil, term: Terminology, cate: Category) throws {
        self.id = id
        self.$terminology.id = try term.requireID()
        self.$category.id = try cate.requireID()
    }
}
