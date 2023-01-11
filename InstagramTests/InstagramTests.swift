//
//  InstagramTests.swift
//  InstagramTests
//
//  Created by Jason Chau on 2023-01-10.
//

@testable import Instagram

import XCTest

final class InstagramTests: XCTestCase {
    
    func testNotificationIDCreation(){
        let first = NotificationManager.newIdentifier()
        let second = NotificationManager.newIdentifier()
        XCTAssertNotEqual(first, second)
    }

}
