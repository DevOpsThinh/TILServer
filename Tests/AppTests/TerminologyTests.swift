//
//  TerminologyTests.swift
//
//  Created by Nguyễn Trường Thịnh on 16/07/2022.
//
@testable import App
import XCTVapor

final class TerminologyTests: XCTestCase {
    /// The common properties
    let termsURI = "/api/terminologies/"
    let termShort = "IT"
    let termLong = "Information Technology"
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
    }

    override func tearDown() {
        app.shutdown()
    }

    func testTermsCanBeRetrievedFromAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let term1 = try Terminology.create(short: termShort, long: termLong, on: app.db)
        _ = try Terminology.create(on: app.db)

        /// When:
        try app.test(.GET, termsURI, afterResponse: {res in
            /// Then:
            let terms = try res.content.decode([Terminology].self)
            XCTAssertEqual(terms.count, 2)
            XCTAssertEqual(terms[0].short, termShort)
            XCTAssertEqual(terms[0].long, termLong)
            XCTAssertEqual(terms[0].id, term1.id)
        })
    }

    func testTermCanBeSavedWithAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let user = try User.create(on: app.db)
        let createTermData = CreateTermData(short: termShort, long: termLong, userID: user.id!)

        /// When:
        try app.test(.POST, termsURI, beforeRequest: { req in
            try req.content.encode(createTermData)
        }, afterResponse: { res in
            /// Then:
            let receivedTerm = try res.content.decode(Terminology.self)
            XCTAssertEqual(receivedTerm.short, termShort)
            XCTAssertEqual(receivedTerm.long, termLong)
            XCTAssertNotNil(receivedTerm.id)

            /// When:
            try app.test(.GET, termsURI, afterResponse: { allTermsRes in
                /// Then:
                let terms = try allTermsRes.content.decode([Terminology].self)
                XCTAssertEqual(terms.count, 1)
                XCTAssertEqual(terms[0].short, termShort)
                XCTAssertEqual(terms[0].long, termLong)
                XCTAssertEqual(terms[0].id, receivedTerm.id)
            })
        })
    }

    func testTakingASingleTermFromTheAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let term = try Terminology.create(short: termShort, long: termLong, on: app.db)
        /// When:
        try app.test(.GET, "\(termsURI)\(term.id!)", afterResponse: { res in
            /// Then:
            let returnedTerm = try res.content.decode(Terminology.self)
            XCTAssertEqual(returnedTerm.short, termShort)
            XCTAssertEqual(returnedTerm.long, termLong)
            XCTAssertEqual(returnedTerm.id, term.id)
        })
    }

    func testUpdatingATerm() throws {
        /// Given: Define some expected values & initialize conditions
        let term = try Terminology.create(short: termShort, long: termLong, on: app.db)
        let newUser = try User.create(on: app.db)
        let newTermLong = "I'm Terrible"
        let updatedTermData = CreateTermData(short: termShort, long: newTermLong, userID: newUser.id!)

        /// When:
        try app.test(.PUT, "\(termsURI)\(term.id!)", beforeRequest: {req in
            try req.content.encode(updatedTermData)
        })

        try app.test(.GET, "\(termsURI)\(term.id!)", afterResponse: { res in
            /// Then:
            let returnedTerm = try res.content.decode(Terminology.self)
            XCTAssertEqual(returnedTerm.short, termShort)
            XCTAssertEqual(returnedTerm.long, newTermLong)
            XCTAssertEqual(returnedTerm.$user.id, newUser.id)
        })
    }

    func testDeletingATerm() throws {
        /// Given: Define some expected values & initialize conditions
        let term = try Terminology.create(on: app.db)

        /// When:
        try app.test(.GET, termsURI, afterResponse: {res in
            /// Then:
            let terms = try res.content.decode([Terminology].self)
            XCTAssertEqual(terms.count, 1)
        })
        /// When:
        try app.test(.DELETE, "\(termsURI)\(term.id!)")

        try app.test(.GET, termsURI, afterResponse: {res in
            /// Then:
            let newTerms = try res.content.decode([Terminology].self)
            XCTAssertEqual(newTerms.count, 0)
        })
    }

    func testSearchTermShort() throws {
        /// Given: Define some expected values & initialize conditions
        let term = try Terminology.create(short: termShort, long: termLong, on: app.db)
        /// When:
        try app.test(.GET, "\(termsURI)search?term=IT", afterResponse: { res in
            /// Then;
            let terms = try res.content.decode([Terminology].self)
            XCTAssertEqual(terms.count, 1)
            XCTAssertEqual(terms[0].id, term.id)
            XCTAssertEqual(terms[0].short, termShort)
            XCTAssertEqual(terms[0].long, termLong)
        })
    }

    func testSearchTermLong() throws {
        /// Given: Define some expected values & initialize conditions
        let term = try Terminology.create(short: termShort, long: termLong, on: app.db)
        /// When:
        try app.test(.GET, "\(termsURI)search?term=Information+Technology", afterResponse: { res in
            /// Then:
            let terms = try res.content.decode([Terminology].self)
            XCTAssertEqual(terms.count, 1)
            XCTAssertEqual(terms[0].id, term.id)
            XCTAssertEqual(terms[0].short, termShort)
            XCTAssertEqual(terms[0].long, termLong)
        })
    }

    func testTakingFirstTerm() throws {
        /// Given: Define some expected values & initialize conditions
        let term = try Terminology.create(short: termShort, long: termLong, on: app.db)
        _ = try Terminology.create(on: app.db)
        _ = try Terminology.create(on: app.db)
        /// When:
        try app.test(.GET, "\(termsURI)first", afterResponse: { res in
            /// Then:
            let firstTerm = try res.content.decode(Terminology.self)
            XCTAssertEqual(firstTerm.id, term.id)
            XCTAssertEqual(firstTerm.short, termShort)
            XCTAssertEqual(firstTerm.long, termLong)
       })
     }

     func testSortingTerms() throws {
         /// Given: Define some expected values & initialize conditions
         let short2 = "LOL"
         let long2 = "Laugh Out Loud"
         let term1 = try Terminology.create(short: termShort, long: termLong, on: app.db)
         let term2 = try Terminology.create(short: short2, long: long2, on: app.db)

         /// When:
         try app.test(.GET, "\(termsURI)sorted", afterResponse: { res in
             /// Then:
             let sortedTerms = try res.content.decode([Terminology].self)
             XCTAssertEqual(sortedTerms[0].id, term1.id)
             XCTAssertEqual(sortedTerms[1].id, term2.id)
       })
     }

     func testTakingATermsUser() throws {
         /// Given: Define some expected values & initialize conditions
         let user = try User.create(on: app.db)
         let term = try Terminology.create(user: user, on: app.db)

         /// When:
         try app.test(.GET, "\(termsURI)\(term.id!)/user", afterResponse: { res in
             /// Then:
             let termsUser = try res.content.decode(User.self)
             XCTAssertEqual(termsUser.id, user.id)
             XCTAssertEqual(termsUser.name, user.name)
             XCTAssertEqual(termsUser.username, user.username)
       })
     }

     func testTermsCategories() throws {
         /// Given: Define some expected values & initialize conditions
         let category = try Category.create(on: app.db)
         let category2 = try Category.create(name: "Terminology", on: app.db)
         let term = try Terminology.create(on: app.db)

         /// When:
         try app.test(.POST, "\(termsURI)\(term.id!)/categories/\(category.id!)")
         try app.test(.POST, "\(termsURI)\(term.id!)/categories/\(category2.id!)")

         try app.test(.GET, "\(termsURI)\(term.id!)/categories", afterResponse: { res in
           /// Then:
           let categories = try res.content.decode([App.Category].self)
           XCTAssertEqual(categories.count, 2)
           XCTAssertEqual(categories[0].id, category.id)
           XCTAssertEqual(categories[0].name, category.name)
           XCTAssertEqual(categories[1].id, category2.id)
           XCTAssertEqual(categories[1].name, category2.name)
       })
         /// When:
         try app.test(.DELETE, "\(termsURI)\(term.id!)/categories/\(category.id!)")

         try app.test(.GET, "\(termsURI)\(term.id!)/categories", afterResponse: { res in
           /// Then:
           let newCategories = try res.content.decode([App.Category].self)
           XCTAssertEqual(newCategories.count, 1)
       })
     }
}
