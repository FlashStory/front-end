//
//  Topic.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/26/24.
//

import Foundation

struct TopicView: Identifiable, Codable {
    let id: String
    let name: String
    let collections: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, collections
    }
}
