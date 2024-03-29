//
//  ImageCommentsEndpoint.swift
//  EssentialsFeedAPI
//
//  Created by Chico Pereira on 13/06/2022.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
//    case post(imageId: UUID, comment: ImageComment)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}
