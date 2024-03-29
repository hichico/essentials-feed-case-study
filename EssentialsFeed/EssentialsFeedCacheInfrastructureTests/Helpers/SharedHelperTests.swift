//
//  SharedHelperTests.swift
//  EssentialsFeedCacheInfrastructureTests
//
//  Created by Chico Pereira on 25/04/2022.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
