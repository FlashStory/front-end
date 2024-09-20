//
//  Post.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let content: [String]
    let collectionId: String
    let collectionName: String
    var reactions: Reactions
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, collectionId, collectionName, reactions
    }
}
