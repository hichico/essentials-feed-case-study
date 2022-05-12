//
//  ImageCommentsMapper.swift
//  EssentialsFeedAPI
//
//  Created by Chico Pereira on 12/05/2022.
//

import Foundation

class ImageCommentsMapper {
   private struct Root: Decodable {
       let items: [RemoteFeedItem]
   }
   
   private static var OK_200: Int { return 200 }
   
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.isOK, let root = try?
               JSONDecoder().decode(Root.self, from: data) else {
                   throw RemoteImageCommentsLoader.Error.invalidData
               }
       return root.items
   }
}
