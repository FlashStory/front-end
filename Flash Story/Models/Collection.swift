//
//  Collection.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

struct Collection: Identifiable, Codable {
    let id: String
    let name: String
    let avatar: String
    let posts: [Post]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, avatar, posts
    }
}

struct CollectionView: Identifiable, Codable {
    let id: String
    let name: String
    let avatar: String
    let posts: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, avatar, posts
    }
}
