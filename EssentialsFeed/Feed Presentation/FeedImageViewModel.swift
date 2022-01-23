//
//  FeedImageViewModel.swift
//  EssentialsFeed
//
//  Created by Chico Pereira on 23/01/2022.
//

import Foundation

 public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}