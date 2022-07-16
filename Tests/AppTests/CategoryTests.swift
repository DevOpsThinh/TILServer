//
//  CategoryTests.swift
//
//  Created by Nguyễn Trường Thịnh on 16/07/2022.
//
@testable import App
import XCTVapor

final class CategoryTests: XCTestCase {
    /// The common properties
    let categoriesURI = "/api/categories/"
    let categoryName = "Terminology"
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testCategoriesCanBeRetrievedFromAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let category = try Category.create(name: categoryName, on: app.db)
        _ = try Category.create(on: app.db)

        /// When:
        try app.test(.GET, categoriesURI, afterResponse: { res in
            /// Then:
            let categories = try res.content.decode([App.Category].self)
            XCTAssertEqual(categories.count, 2)
            XCTAssertEqual(categories[0].name, categoryName)
            XCTAssertEqual(categories[0].id, category.id)
        })
    }

    func testCategoryCanBeSavedWithAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let category = Category(name: categoryName)

        /// When:
        try app.test(.POST, categoriesURI, beforeRequest: { req in
            try req.content.encode(category)
        }, afterResponse: { res in
            /// Then:
            let receivedCategory = try res.content.decode(Category.self)
            XCTAssertEqual(receivedCategory.name, categoryName)
            XCTAssertNotNil(receivedCategory.id)

            /// When:
            try app.test(.GET, categoriesURI, afterResponse: { res in
                /// Then:
                let categories = try res.content.decode([App.Category].self)
                XCTAssertEqual(categories.count, 1)
                XCTAssertEqual(categories[0].name, categoryName)
                XCTAssertEqual(categories[0].id, receivedCategory.id)
            })
        })
    }

    func testTakingASingleCategoryFromTheAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let category = try Category.create(name: categoryName, on: app.db)

        /// When:
        try app.test(.GET, "\(categoriesURI)\(category.id!)", afterResponse: { res in
            /// Then:
            let returnedCategory = try res.content.decode(Category.self)
            XCTAssertEqual(returnedCategory.name, categoryName)
            XCTAssertEqual(returnedCategory.id, category.id)
        })
    }

    func testTakingACategoriesTermsFromTheAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let termShort = "IT"
        let termLong = "Information Technology"
        let term = try Terminology.create(short: termShort, long: termLong, on: app.db)
        let term2 = try Terminology.create(on: app.db)

        let category = try Category.create(name: categoryName, on: app.db)
        /// When:
        try app.test(.POST, "/api/terminologies/\(term.id!)/categories/\(category.id!)")
        try app.test(.POST, "/api/terminologies/\(term2.id!)/categories/\(category.id!)")

        try app.test(.GET, "\(categoriesURI)\(category.id!)/terminologies", afterResponse: { res in
            /// Then:
            let terms = try res.content.decode([Terminology].self)
            XCTAssertEqual(terms.count, 2)
            XCTAssertEqual(terms[0].id, term.id)
            XCTAssertEqual(terms[0].short, termShort)
            XCTAssertEqual(terms[0].long, termLong)
        })
    }
}
