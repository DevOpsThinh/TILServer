//
//  UserTests.swift
//  
//
//  Created by Nguyễn Trường Thịnh on 15/07/2022.
//
@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    /// The common properties
    let usersName = "Thinh"
    let usersUsername = "devopsthinh"
    let usersURI = "/api/users/"
    var app: Application!

    override func setUpWithError() throws {
        app = try Application.testable()
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testUsersCanBeRetrievedFromAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let user = try User.create(name: usersName, username: usersUsername, on: app.db)

        _ = try User.create(on: app.db)

        /// When:
        try app.test(.GET, usersURI, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            /// Then:
            let users = try res.content.decode([User].self)

            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, usersName)
            XCTAssertEqual(users[0].username, usersUsername)
            XCTAssertEqual(users[0].id, user.id)
        })

    }

    func testUserCanBeSavedWithAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let user = User(name: usersName, username: usersUsername)

        /// When:
        try app.test(.POST, usersURI, beforeRequest: { req in
            try req.content.encode(user)
        }, afterResponse: { res in
            /// Then:
            let receivedUser = try res.content.decode(User.self)
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertNotNil(receivedUser.id)

            /// When:
            try app.test(.GET, usersURI, afterResponse: { secRes in
                /// Then:
                let users = try secRes.content.decode([User].self)
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].name, usersName)
                XCTAssertEqual(users[0].username, usersUsername)
                XCTAssertEqual(users[0].id, receivedUser.id)
            })
        })

    }

    func testTakingAsingleUserFromTheAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: app.db
        )

        /// When:
        try app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { res in
            /// Then:
            let receivedUser = try res.content.decode(User.self)
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertEqual(receivedUser.id, user.id)
        })
    }

    func testTakingAUsersTerminologiesFromTheAPI() throws {
        /// Given: Define some expected values & initialize conditions
        let user = try User.create(on: app.db)

        let termShort = "IT"
        let termLong = "Information Technology"

        let term1 = try Terminology.create(
            short: termShort,
            long: termLong,
            user: user,
            on: app.db)
        _ = try Terminology.create(short: "PC", long: "Personal Computer", user: user, on: app.db)

        /// When:
        try app.test(.GET, "\(usersURI)\(user.id!)/terminologies",
                     afterResponse: { res in
            /// Then;
            let terminologies = try res.content.decode([Terminology].self)
            XCTAssertEqual(terminologies.count, 2)
            XCTAssertEqual(terminologies[0].id, term1.id)
            XCTAssertEqual(terminologies[0].short, termShort)
            XCTAssertEqual(terminologies[0].long, termLong)
        })
    }

    //    func testUsersCanBeRetrievedFromAPI() throws {
    //        /// Given: Define some expected values & initialize conditions
    //        let expName = "Thinh"
    //        let expUsername = "devopsthinh"
    //
    //        let app = Application(.testing)
    //        defer {app.shutdown()}
    //        try configure(app)
    //        try app.autoRevert().wait()
    //        try app.autoMigrate().wait()
    //
    //        let user = User(name: expName, username: expUsername)
    //
    //        try user
    //            .save(on: app.db).wait()
    //        try User(name: "Adam", username: "adam_eva")
    //            .save(on: app.db).wait()
    //        /// When:
    //        try app.test(.GET, "/api/users", afterResponse: { res in
    //            XCTAssertEqual(res.status, .ok)
    //            /// Then:
    //            let users = try res.content.decode([User].self)
    //            XCTAssertEqual(users.count, 2)
    //            XCTAssertEqual(users[0].name, expName)
    //            XCTAssertEqual(users[0].username, expUsername)
    //            XCTAssertEqual(users[0].id, user.id)
    //        })
    //    }
}
